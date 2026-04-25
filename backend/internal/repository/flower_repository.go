package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/kimura/dating/backend/internal/domain"
)

type FlowerRepository struct {
	db *sql.DB
}

func NewFlowerRepository(db *sql.DB) *FlowerRepository {
	return &FlowerRepository{db: db}
}

func (r *FlowerRepository) ListFlowers(ctx context.Context) ([]domain.Flower, error) {
	return r.listFlowersByQuery(ctx, `
		SELECT id, name, image_url, description, price_points, purchaser_count, purchase_count, published, created_at, updated_at
		FROM flowers
		ORDER BY created_at DESC, id DESC
	`)
}

func (r *FlowerRepository) ListPublishedFlowers(ctx context.Context) ([]domain.Flower, error) {
	return r.listFlowersByQuery(ctx, `
		SELECT id, name, image_url, description, price_points, purchaser_count, purchase_count, published, created_at, updated_at
		FROM flowers
		WHERE published = TRUE
		ORDER BY created_at DESC, id DESC
	`)
}

func (r *FlowerRepository) listFlowersByQuery(ctx context.Context, query string) ([]domain.Flower, error) {
	rows, err := r.db.QueryContext(ctx, query)
	if err != nil {
		return nil, fmt.Errorf("query flowers: %w", err)
	}
	defer rows.Close()

	items := make([]domain.Flower, 0)
	for rows.Next() {
		item, err := scanFlower(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate flowers: %w", err)
	}

	return items, nil
}

func (r *FlowerRepository) GetFlowerByID(ctx context.Context, id string) (domain.Flower, error) {
	row := r.db.QueryRowContext(ctx, `
		SELECT id, name, image_url, description, price_points, purchaser_count, purchase_count, published, created_at, updated_at
		FROM flowers
		WHERE id = $1
	`, id)

	return scanFlower(row)
}

func (r *FlowerRepository) CreateFlower(ctx context.Context, id string, input domain.CreateFlowerInput) (domain.Flower, error) {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO flowers (id, name, image_url, description, price_points, published)
		VALUES ($1, $2, $3, $4, $5, $6)
	`, id, input.Name, input.ImageURL, input.Description, input.PricePoints, input.Published)
	if err != nil {
		return domain.Flower{}, fmt.Errorf("create flower: %w", err)
	}

	return r.GetFlowerByID(ctx, id)
}

func (r *FlowerRepository) UpdateFlower(ctx context.Context, id string, input domain.UpdateFlowerInput) (domain.Flower, error) {
	result, err := r.db.ExecContext(ctx, `
		UPDATE flowers
		SET name = $2,
			image_url = $3,
			description = $4,
			price_points = $5,
			published = $6,
			updated_at = NOW()
		WHERE id = $1
	`, id, input.Name, input.ImageURL, input.Description, input.PricePoints, input.Published)
	if err != nil {
		return domain.Flower{}, fmt.Errorf("update flower: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return domain.Flower{}, fmt.Errorf("flower update result: %w", err)
	}
	if rowsAffected == 0 {
		return domain.Flower{}, sql.ErrNoRows
	}

	return r.GetFlowerByID(ctx, id)
}

func (r *FlowerRepository) AcquireFlower(ctx context.Context, flowerID, userID string) (domain.FlowerAcquireResult, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return domain.FlowerAcquireResult{}, fmt.Errorf("begin acquire flower: %w", err)
	}

	flower, err := getFlowerByIDTx(ctx, tx, flowerID)
	if err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, err
	}
	if !flower.Published {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, sql.ErrNoRows
	}

	user, err := getUserByIDTx(ctx, tx, userID)
	if err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, err
	}
	if user.PointBalance < flower.PricePoints {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, fmt.Errorf("insufficient points")
	}

	if _, err := tx.ExecContext(ctx, `
		INSERT INTO flower_purchases (flower_id, user_id, price_points)
		VALUES ($1, $2, $3)
	`, flowerID, userID, flower.PricePoints); err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, fmt.Errorf("insert flower purchase: %w", err)
	}

	if _, err := tx.ExecContext(ctx, `
		UPDATE users
		SET point_balance = point_balance - $2,
			updated_at = NOW()
		WHERE id = $1
	`, userID, flower.PricePoints); err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, fmt.Errorf("decrease user points: %w", err)
	}

	if _, err := tx.ExecContext(ctx, `
		UPDATE flowers
		SET purchase_count = purchase_count + 1,
			purchaser_count = (
				SELECT COUNT(DISTINCT user_id)
				FROM flower_purchases
				WHERE flower_id = $1
			),
			updated_at = NOW()
		WHERE id = $1
	`, flowerID); err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, fmt.Errorf("update flower counters: %w", err)
	}

	var ownedCount int
	if err := tx.QueryRowContext(ctx, `
		SELECT COUNT(*)
		FROM flower_purchases
		WHERE flower_id = $1 AND user_id = $2
	`, flowerID, userID).Scan(&ownedCount); err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, fmt.Errorf("count owned flowers: %w", err)
	}

	updatedFlower, err := getFlowerByIDTx(ctx, tx, flowerID)
	if err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, err
	}

	updatedUser, err := getUserByIDTx(ctx, tx, userID)
	if err != nil {
		_ = tx.Rollback()
		return domain.FlowerAcquireResult{}, err
	}

	if err := tx.Commit(); err != nil {
		return domain.FlowerAcquireResult{}, fmt.Errorf("commit acquire flower: %w", err)
	}

	return domain.FlowerAcquireResult{
		Flower:      updatedFlower,
		User:        updatedUser,
		OwnedCount:  ownedCount,
		SpentPoints: flower.PricePoints,
	}, nil
}

func (r *FlowerRepository) ListOwnedFlowers(ctx context.Context, userID string) (domain.MyFlowersResponse, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT
			f.id,
			f.name,
			f.image_url,
			f.description,
			f.price_points,
			f.purchaser_count,
			f.purchase_count,
			f.published,
			f.created_at,
			f.updated_at,
			COUNT(fp.flower_id) AS owned_count,
			MAX(fp.purchased_at) AS last_owned_at
		FROM flower_purchases fp
		INNER JOIN flowers f ON f.id = fp.flower_id
		WHERE fp.user_id = $1
		GROUP BY
			f.id, f.name, f.image_url, f.description, f.price_points,
			f.purchaser_count, f.purchase_count, f.published, f.created_at, f.updated_at
		ORDER BY MAX(fp.purchased_at) DESC, f.id DESC
	`, userID)
	if err != nil {
		return domain.MyFlowersResponse{}, fmt.Errorf("query owned flowers: %w", err)
	}
	defer rows.Close()

	items := make([]domain.OwnedFlowerItem, 0)
	for rows.Next() {
		var item domain.OwnedFlowerItem
		var createdAt time.Time
		var updatedAt time.Time
		var lastOwnedAt time.Time
		if err := rows.Scan(
			&item.Flower.ID,
			&item.Flower.Name,
			&item.Flower.ImageURL,
			&item.Flower.Description,
			&item.Flower.PricePoints,
			&item.Flower.PurchaserCount,
			&item.Flower.PurchaseCount,
			&item.Flower.Published,
			&createdAt,
			&updatedAt,
			&item.OwnedCount,
			&lastOwnedAt,
		); err != nil {
			return domain.MyFlowersResponse{}, fmt.Errorf("scan owned flower: %w", err)
		}
		item.Flower.CreatedAt = createdAt.Format(time.RFC3339)
		item.Flower.UpdatedAt = updatedAt.Format(time.RFC3339)
		item.LastOwnedAt = lastOwnedAt.Format(time.RFC3339)
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return domain.MyFlowersResponse{}, fmt.Errorf("iterate owned flowers: %w", err)
	}

	return domain.MyFlowersResponse{
		Purchased: items,
		Gifted:    []domain.OwnedFlowerItem{},
	}, nil
}

type flowerScanner interface {
	Scan(dest ...any) error
}

func scanFlower(scanner flowerScanner) (domain.Flower, error) {
	var item domain.Flower
	var createdAt time.Time
	var updatedAt time.Time

	err := scanner.Scan(
		&item.ID,
		&item.Name,
		&item.ImageURL,
		&item.Description,
		&item.PricePoints,
		&item.PurchaserCount,
		&item.PurchaseCount,
		&item.Published,
		&createdAt,
		&updatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return domain.Flower{}, err
		}
		return domain.Flower{}, fmt.Errorf("scan flower: %w", err)
	}

	item.CreatedAt = createdAt.Format(time.RFC3339)
	item.UpdatedAt = updatedAt.Format(time.RFC3339)
	return item, nil
}

func getFlowerByIDTx(ctx context.Context, tx *sql.Tx, id string) (domain.Flower, error) {
	row := tx.QueryRowContext(ctx, `
		SELECT id, name, image_url, description, price_points, purchaser_count, purchase_count, published, created_at, updated_at
		FROM flowers
		WHERE id = $1
		FOR UPDATE
	`, id)
	return scanFlower(row)
}

func getUserByIDTx(ctx context.Context, tx *sql.Tx, id string) (domain.User, error) {
	row := tx.QueryRowContext(ctx, `
		SELECT id, email, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason, point_balance, created_at, last_login_at, updated_at
		FROM users
		WHERE id = $1
		FOR UPDATE
	`, id)
	return scanUser(row)
}
