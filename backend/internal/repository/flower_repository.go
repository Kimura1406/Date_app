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
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, name, image_url, description, price_points, purchaser_count, purchase_count, published, created_at, updated_at
		FROM flowers
		ORDER BY created_at DESC, id DESC
	`)
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
