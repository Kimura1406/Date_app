package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/kimura/dating/backend/internal/domain"
)

type SessionRepository struct {
	db *sql.DB
}

func NewSessionRepository(db *sql.DB) *SessionRepository {
	return &SessionRepository{db: db}
}

func (r *SessionRepository) CreateSession(ctx context.Context, id, userID, tokenHash string, expiresAt time.Time) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO refresh_tokens (id, user_id, token_hash, expires_at)
		VALUES ($1, $2, $3, $4)
	`, id, userID, tokenHash, expiresAt)
	if err != nil {
		return fmt.Errorf("create session: %w", err)
	}
	return nil
}

func (r *SessionRepository) GetSessionByTokenHash(ctx context.Context, tokenHash string) (domain.Session, error) {
	var session domain.Session
	var expiresAt time.Time
	var revokedAt sql.NullTime

	err := r.db.QueryRowContext(ctx, `
		SELECT id, user_id, token_hash, expires_at, revoked_at
		FROM refresh_tokens
		WHERE token_hash = $1
	`, tokenHash).Scan(&session.ID, &session.UserID, &session.TokenHash, &expiresAt, &revokedAt)
	if err != nil {
		if err == sql.ErrNoRows {
			return domain.Session{}, err
		}
		return domain.Session{}, fmt.Errorf("query session: %w", err)
	}

	session.ExpiresAt = expiresAt.Format(time.RFC3339)
	if revokedAt.Valid {
		session.RevokedAt = revokedAt.Time.Format(time.RFC3339)
	}

	return session, nil
}

func (r *SessionRepository) RevokeSessionByTokenHash(ctx context.Context, tokenHash string) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE refresh_tokens
		SET revoked_at = NOW()
		WHERE token_hash = $1 AND revoked_at IS NULL
	`, tokenHash)
	if err != nil {
		return fmt.Errorf("revoke session: %w", err)
	}
	rows, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("session revoke result: %w", err)
	}
	if rows == 0 {
		return sql.ErrNoRows
	}
	return nil
}
