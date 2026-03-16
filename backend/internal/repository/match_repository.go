package repository

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/kimura/dating/backend/internal/domain"
)

type MatchRepository struct {
	db *sql.DB
}

func NewMatchRepository(db *sql.DB) *MatchRepository {
	return &MatchRepository{db: db}
}

func (r *MatchRepository) ListMatches(ctx context.Context) ([]domain.Match, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, name, last_message, last_seen, status
		FROM matches
		ORDER BY created_at ASC, id ASC
	`)
	if err != nil {
		return nil, fmt.Errorf("query matches: %w", err)
	}
	defer rows.Close()

	matches := make([]domain.Match, 0)
	for rows.Next() {
		var match domain.Match
		if err := rows.Scan(
			&match.ID,
			&match.Name,
			&match.LastMessage,
			&match.LastSeen,
			&match.Status,
		); err != nil {
			return nil, fmt.Errorf("scan match: %w", err)
		}
		matches = append(matches, match)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate matches: %w", err)
	}

	return matches, nil
}
