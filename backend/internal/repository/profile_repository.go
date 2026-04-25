package repository

import (
	"context"
	"database/sql"
	"fmt"
	"strings"

	"github.com/kimura/dating/backend/internal/domain"
)

type ProfileRepository struct {
	db *sql.DB
}

func NewProfileRepository(db *sql.DB) *ProfileRepository {
	return &ProfileRepository{db: db}
}

func (r *ProfileRepository) ListDiscoveryProfiles(ctx context.Context, filter domain.DiscoveryFilter) ([]domain.Profile, error) {
	query := `
		SELECT
			id,
			name,
			age,
			job,
			COALESCE(NULLIF(bio, ''), NULLIF(dating_reason, ''), '') AS bio,
			COALESCE(NULLIF(distance, ''), NULLIF(prefecture, ''), NULLIF(country, ''), '') AS distance,
			interests,
			country,
			'' AS gender,
			COALESCE(NULLIF(prefecture, ''), NULLIF(country, ''), '') AS location,
			'' AS image_url,
			(created_at >= NOW() - INTERVAL '7 days') AS is_new
		FROM users
		WHERE 1 = 1
	`
	args := make([]any, 0, 6)
	argIndex := 1

	query += " AND role = 'user'"

	if value := strings.TrimSpace(filter.ExcludeUserID); value != "" {
		query += fmt.Sprintf(" AND id <> $%d", argIndex)
		args = append(args, value)
		argIndex++
	}

	if value := strings.TrimSpace(filter.Country); value != "" {
		query += fmt.Sprintf(" AND lower(country) = lower($%d)", argIndex)
		args = append(args, value)
		argIndex++
	}
	if value := strings.TrimSpace(filter.Job); value != "" {
		query += fmt.Sprintf(" AND lower(job) = lower($%d)", argIndex)
		args = append(args, value)
		argIndex++
	}
	if value := strings.TrimSpace(filter.Location); value != "" {
		query += fmt.Sprintf(" AND (lower(prefecture) LIKE lower($%d) OR lower(country) LIKE lower($%d))", argIndex, argIndex)
		args = append(args, "%"+value+"%")
		argIndex++
	}
	if filter.MinAge > 0 {
		query += fmt.Sprintf(" AND age >= $%d", argIndex)
		args = append(args, filter.MinAge)
		argIndex++
	}
	if filter.MaxAge > 0 {
		query += fmt.Sprintf(" AND age <= $%d", argIndex)
		args = append(args, filter.MaxAge)
		argIndex++
	}

	query += " ORDER BY (created_at >= NOW() - INTERVAL '7 days') DESC, created_at DESC, id ASC"

	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("query discovery users: %w", err)
	}
	defer rows.Close()

	profiles := make([]domain.Profile, 0)
	for rows.Next() {
		var profile domain.Profile
		var interestsRaw sql.NullString
		if err := rows.Scan(
			&profile.ID,
			&profile.Name,
			&profile.Age,
			&profile.Job,
			&profile.Bio,
			&profile.Distance,
			&interestsRaw,
			&profile.Country,
			&profile.Gender,
			&profile.Location,
			&profile.ImageURL,
			&profile.IsNew,
		); err != nil {
			return nil, fmt.Errorf("scan profile: %w", err)
		}
		profile.Interests, err = parseTextArray(interestsRaw.String)
		if err != nil {
			return nil, fmt.Errorf("parse profile interests: %w", err)
		}
		profiles = append(profiles, profile)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate profiles: %w", err)
	}

	return profiles, nil
}
