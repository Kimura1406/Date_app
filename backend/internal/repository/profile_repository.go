package repository

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/kimura/dating/backend/internal/domain"
)

type ProfileRepository struct {
	db *sql.DB
}

func NewProfileRepository(db *sql.DB) *ProfileRepository {
	return &ProfileRepository{db: db}
}

func (r *ProfileRepository) ListDiscoveryProfiles(ctx context.Context) ([]domain.Profile, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, name, age, job, bio, distance, interests
		FROM profiles
		ORDER BY created_at ASC, id ASC
	`)
	if err != nil {
		return nil, fmt.Errorf("query profiles: %w", err)
	}
	defer rows.Close()

	profiles := make([]domain.Profile, 0)
	for rows.Next() {
		var profile domain.Profile
		if err := rows.Scan(
			&profile.ID,
			&profile.Name,
			&profile.Age,
			&profile.Job,
			&profile.Bio,
			&profile.Distance,
			&profile.Interests,
		); err != nil {
			return nil, fmt.Errorf("scan profile: %w", err)
		}
		profiles = append(profiles, profile)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate profiles: %w", err)
	}

	return profiles, nil
}
