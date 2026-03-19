package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/kimura/dating/backend/internal/domain"
)

type BannerRepository struct {
	db *sql.DB
}

func NewBannerRepository(db *sql.DB) *BannerRepository {
	return &BannerRepository{db: db}
}

func (r *BannerRepository) ListBanners(ctx context.Context) ([]domain.Banner, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, image_url, event_name, display_order, redirect_link, published, created_at, updated_at
		FROM banners
		ORDER BY display_order ASC, created_at DESC, id DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("query banners: %w", err)
	}
	defer rows.Close()

	items := make([]domain.Banner, 0)
	for rows.Next() {
		item, err := scanBanner(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate banners: %w", err)
	}

	return items, nil
}

func (r *BannerRepository) ListPublicBanners(ctx context.Context) ([]domain.Banner, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, image_url, event_name, display_order, redirect_link, published, created_at, updated_at
		FROM banners
		WHERE published = TRUE
		ORDER BY display_order ASC, created_at DESC, id DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("query public banners: %w", err)
	}
	defer rows.Close()

	items := make([]domain.Banner, 0)
	for rows.Next() {
		item, err := scanBanner(rows)
		if err != nil {
			return nil, err
		}
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate public banners: %w", err)
	}

	return items, nil
}

func (r *BannerRepository) GetBannerByID(ctx context.Context, id string) (domain.Banner, error) {
	row := r.db.QueryRowContext(ctx, `
		SELECT id, image_url, event_name, display_order, redirect_link, published, created_at, updated_at
		FROM banners
		WHERE id = $1
	`, id)

	return scanBanner(row)
}

func (r *BannerRepository) CreateBanner(ctx context.Context, id string, input domain.CreateBannerInput) (domain.Banner, error) {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO banners (id, image_url, event_name, display_order, redirect_link, published)
		VALUES ($1, $2, $3, $4, $5, $6)
	`, id, input.ImageURL, input.EventName, input.DisplayOrder, input.RedirectLink, input.Published)
	if err != nil {
		return domain.Banner{}, fmt.Errorf("create banner: %w", err)
	}

	return r.GetBannerByID(ctx, id)
}

func (r *BannerRepository) UpdateBanner(ctx context.Context, id string, input domain.UpdateBannerInput) (domain.Banner, error) {
	result, err := r.db.ExecContext(ctx, `
		UPDATE banners
		SET image_url = $2,
			event_name = $3,
			display_order = $4,
			redirect_link = $5,
			published = $6,
			updated_at = NOW()
		WHERE id = $1
	`, id, input.ImageURL, input.EventName, input.DisplayOrder, input.RedirectLink, input.Published)
	if err != nil {
		return domain.Banner{}, fmt.Errorf("update banner: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return domain.Banner{}, fmt.Errorf("banner update result: %w", err)
	}
	if rowsAffected == 0 {
		return domain.Banner{}, sql.ErrNoRows
	}

	return r.GetBannerByID(ctx, id)
}

type bannerScanner interface {
	Scan(dest ...any) error
}

func scanBanner(scanner bannerScanner) (domain.Banner, error) {
	var item domain.Banner
	var createdAt time.Time
	var updatedAt time.Time

	err := scanner.Scan(
		&item.ID,
		&item.ImageURL,
		&item.EventName,
		&item.DisplayOrder,
		&item.RedirectLink,
		&item.Published,
		&createdAt,
		&updatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return domain.Banner{}, err
		}
		return domain.Banner{}, fmt.Errorf("scan banner: %w", err)
	}

	item.CreatedAt = createdAt.Format(time.RFC3339)
	item.UpdatedAt = updatedAt.Format(time.RFC3339)
	return item, nil
}
