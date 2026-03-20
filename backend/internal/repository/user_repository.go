package repository

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/kimura/dating/backend/internal/domain"
)

type UserRepository struct {
	db *sql.DB
}

func NewUserRepository(db *sql.DB) *UserRepository {
	return &UserRepository{db: db}
}

func (r *UserRepository) ListUsers(ctx context.Context) ([]domain.User, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT id, email, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason, point_balance, created_at, last_login_at, updated_at
		FROM users
		ORDER BY created_at DESC, id DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("query users: %w", err)
	}
	defer rows.Close()

	users := make([]domain.User, 0)
	for rows.Next() {
		user, err := scanUser(rows)
		if err != nil {
			return nil, err
		}
		users = append(users, user)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate users: %w", err)
	}

	return users, nil
}

func (r *UserRepository) GetUserByID(ctx context.Context, id string) (domain.User, error) {
	row := r.db.QueryRowContext(ctx, `
		SELECT id, email, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason, point_balance, created_at, last_login_at, updated_at
		FROM users
		WHERE id = $1
	`, id)

	user, err := scanUser(row)
	if err != nil {
		return domain.User{}, err
	}

	return user, nil
}

func (r *UserRepository) GetCredentialsByEmail(ctx context.Context, email string) (domain.UserCredentials, error) {
	var credentials domain.UserCredentials
	err := r.db.QueryRowContext(ctx, `
		SELECT id, email, role, password_hash
		FROM users
		WHERE email = $1
	`, email).Scan(&credentials.ID, &credentials.Email, &credentials.Role, &credentials.PasswordHash)
	if err != nil {
		if err == sql.ErrNoRows {
			return domain.UserCredentials{}, err
		}
		return domain.UserCredentials{}, fmt.Errorf("query credentials: %w", err)
	}

	return credentials, nil
}

func (r *UserRepository) CreateUser(ctx context.Context, id string, input domain.CreateUserInput, passwordHash string) (domain.User, error) {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO users (id, email, password_hash, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason)
		VALUES ($1, $2, $3, 'user', $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
	`,
		id,
		input.Email,
		passwordHash,
		input.Name,
		input.Age,
		input.Job,
		input.Bio,
		input.Distance,
		input.Interests,
		input.BirthDate,
		input.Country,
		input.Prefecture,
		input.DatingReason,
	)
	if err != nil {
		return domain.User{}, fmt.Errorf("create user: %w", err)
	}

	return r.GetUserByID(ctx, id)
}

func (r *UserRepository) UpdateUser(ctx context.Context, id string, input domain.UpdateUserInput, passwordHash *string) (domain.User, error) {
	query := `
		UPDATE users
		SET email = $2,
			name = $3,
			age = $4,
			job = $5,
			bio = $6,
			distance = $7,
			interests = $8,
			birth_date = $9,
			country = $10,
			prefecture = $11,
			dating_reason = $12,
			updated_at = NOW()
		WHERE id = $1
	`
	args := []any{id, input.Email, input.Name, input.Age, input.Job, input.Bio, input.Distance, input.Interests, input.BirthDate, input.Country, input.Prefecture, input.DatingReason}

	if passwordHash != nil {
		query = `
			UPDATE users
			SET email = $2,
				password_hash = $3,
				name = $4,
				age = $5,
				job = $6,
				bio = $7,
				distance = $8,
				interests = $9,
				birth_date = $10,
				country = $11,
				prefecture = $12,
				dating_reason = $13,
				updated_at = NOW()
			WHERE id = $1
		`
		args = []any{id, input.Email, *passwordHash, input.Name, input.Age, input.Job, input.Bio, input.Distance, input.Interests, input.BirthDate, input.Country, input.Prefecture, input.DatingReason}
	}

	result, err := r.db.ExecContext(ctx, query, args...)
	if err != nil {
		return domain.User{}, fmt.Errorf("update user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return domain.User{}, fmt.Errorf("user update result: %w", err)
	}
	if rowsAffected == 0 {
		return domain.User{}, sql.ErrNoRows
	}

	return r.GetUserByID(ctx, id)
}

func (r *UserRepository) DeleteUser(ctx context.Context, id string) error {
	result, err := r.db.ExecContext(ctx, `DELETE FROM users WHERE id = $1`, id)
	if err != nil {
		return fmt.Errorf("delete user: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("user delete result: %w", err)
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

func (r *UserRepository) UpdateLastLogin(ctx context.Context, id string, loggedInAt time.Time) error {
	result, err := r.db.ExecContext(ctx, `
		UPDATE users
		SET last_login_at = $2,
			updated_at = NOW()
		WHERE id = $1
	`, id, loggedInAt.UTC())
	if err != nil {
		return fmt.Errorf("update last login: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return fmt.Errorf("last login update result: %w", err)
	}
	if rowsAffected == 0 {
		return sql.ErrNoRows
	}

	return nil
}

func (r *UserRepository) AddPoints(ctx context.Context, id string, points int) (domain.User, error) {
	result, err := r.db.ExecContext(ctx, `
		UPDATE users
		SET point_balance = point_balance + $2,
			updated_at = NOW()
		WHERE id = $1
	`, id, points)
	if err != nil {
		return domain.User{}, fmt.Errorf("add user points: %w", err)
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		return domain.User{}, fmt.Errorf("user point update result: %w", err)
	}
	if rowsAffected == 0 {
		return domain.User{}, sql.ErrNoRows
	}

	return r.GetUserByID(ctx, id)
}

func (r *UserRepository) GetLikeSummary(ctx context.Context, targetUserID, viewerUserID string) (domain.UserLikeSummary, error) {
	var summary domain.UserLikeSummary
	summary.TargetUserID = targetUserID

	err := r.db.QueryRowContext(ctx, `
		SELECT
			(SELECT COUNT(*) FROM user_likes WHERE target_user_id = $1) AS like_count,
			EXISTS(
				SELECT 1
				FROM user_likes
				WHERE target_user_id = $1 AND liker_user_id = $2
			) AS liked_by_me
	`, targetUserID, viewerUserID).Scan(&summary.LikeCount, &summary.LikedByMe)
	if err != nil {
		return domain.UserLikeSummary{}, fmt.Errorf("query user like summary: %w", err)
	}

	return summary, nil
}

func (r *UserRepository) ToggleLike(ctx context.Context, targetUserID, viewerUserID string) (domain.UserLikeSummary, error) {
	tx, err := r.db.BeginTx(ctx, nil)
	if err != nil {
		return domain.UserLikeSummary{}, fmt.Errorf("begin toggle like: %w", err)
	}

	var exists bool
	if err := tx.QueryRowContext(ctx, `
		SELECT EXISTS(
			SELECT 1
			FROM user_likes
			WHERE target_user_id = $1 AND liker_user_id = $2
		)
	`, targetUserID, viewerUserID).Scan(&exists); err != nil {
		_ = tx.Rollback()
		return domain.UserLikeSummary{}, fmt.Errorf("check existing like: %w", err)
	}

	if exists {
		if _, err := tx.ExecContext(ctx, `
			DELETE FROM user_likes
			WHERE target_user_id = $1 AND liker_user_id = $2
		`, targetUserID, viewerUserID); err != nil {
			_ = tx.Rollback()
			return domain.UserLikeSummary{}, fmt.Errorf("delete like: %w", err)
		}
	} else {
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO user_likes (target_user_id, liker_user_id)
			VALUES ($1, $2)
		`, targetUserID, viewerUserID); err != nil {
			_ = tx.Rollback()
			return domain.UserLikeSummary{}, fmt.Errorf("insert like: %w", err)
		}
	}

	var summary domain.UserLikeSummary
	summary.TargetUserID = targetUserID
	if err := tx.QueryRowContext(ctx, `
		SELECT
			(SELECT COUNT(*) FROM user_likes WHERE target_user_id = $1) AS like_count,
			EXISTS(
				SELECT 1
				FROM user_likes
				WHERE target_user_id = $1 AND liker_user_id = $2
			) AS liked_by_me
	`, targetUserID, viewerUserID).Scan(&summary.LikeCount, &summary.LikedByMe); err != nil {
		_ = tx.Rollback()
		return domain.UserLikeSummary{}, fmt.Errorf("reload user like summary: %w", err)
	}

	if err := tx.Commit(); err != nil {
		return domain.UserLikeSummary{}, fmt.Errorf("commit toggle like: %w", err)
	}

	return summary, nil
}

func (r *UserRepository) ListUsersWhoLiked(ctx context.Context, targetUserID string) ([]domain.UserLiker, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT u.id, u.name, u.birth_date, u.country, ul.created_at
		FROM user_likes ul
		INNER JOIN users u ON u.id = ul.liker_user_id
		WHERE ul.target_user_id = $1
		ORDER BY ul.created_at DESC, u.id DESC
	`, targetUserID)
	if err != nil {
		return nil, fmt.Errorf("query users who liked: %w", err)
	}
	defer rows.Close()

	items := make([]domain.UserLiker, 0)
	for rows.Next() {
		var item domain.UserLiker
		var birthDate time.Time
		var likedAt time.Time
		if err := rows.Scan(
			&item.ID,
			&item.Name,
			&birthDate,
			&item.Country,
			&likedAt,
		); err != nil {
			return nil, fmt.Errorf("scan user liker: %w", err)
		}
		item.BirthDate = birthDate.Format("2006-01-02")
		item.LikedAt = likedAt.Format(time.RFC3339)
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate users who liked: %w", err)
	}

	return items, nil
}

func (r *UserRepository) BlockUser(ctx context.Context, blockedUserID, blockerUserID string) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO user_blocks (blocked_user_id, blocker_user_id)
		VALUES ($1, $2)
		ON CONFLICT (blocked_user_id, blocker_user_id) DO NOTHING
	`, blockedUserID, blockerUserID)
	if err != nil {
		return fmt.Errorf("insert user block: %w", err)
	}

	return nil
}

func (r *UserRepository) ListBlockedUsers(ctx context.Context, blockerUserID string) ([]domain.BlockedUser, error) {
	rows, err := r.db.QueryContext(ctx, `
		SELECT u.id, u.name, u.birth_date, u.country, ub.created_at
		FROM user_blocks ub
		INNER JOIN users u ON u.id = ub.blocked_user_id
		WHERE ub.blocker_user_id = $1
		ORDER BY ub.created_at DESC, u.id DESC
	`, blockerUserID)
	if err != nil {
		return nil, fmt.Errorf("query blocked users: %w", err)
	}
	defer rows.Close()

	items := make([]domain.BlockedUser, 0)
	for rows.Next() {
		var item domain.BlockedUser
		var birthDate time.Time
		var blockedAt time.Time
		if err := rows.Scan(
			&item.ID,
			&item.Name,
			&birthDate,
			&item.Country,
			&blockedAt,
		); err != nil {
			return nil, fmt.Errorf("scan blocked user: %w", err)
		}
		item.BirthDate = birthDate.Format("2006-01-02")
		item.BlockedAt = blockedAt.Format(time.RFC3339)
		items = append(items, item)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate blocked users: %w", err)
	}

	return items, nil
}

func (r *UserRepository) ReportUser(ctx context.Context, reportedUserID, reporterUserID, reason string) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO user_reports (reported_user_id, reporter_user_id, reason)
		VALUES ($1, $2, $3)
	`, reportedUserID, reporterUserID, reason)
	if err != nil {
		return fmt.Errorf("insert user report: %w", err)
	}

	return nil
}

type userScanner interface {
	Scan(dest ...any) error
}

func scanUser(scanner userScanner) (domain.User, error) {
	var user domain.User
	var createdAt time.Time
	var lastLoginAt sql.NullTime
	var updatedAt time.Time
	var interestsRaw sql.NullString
	var birthDate time.Time

	err := scanner.Scan(
		&user.ID,
		&user.Email,
		&user.Role,
		&user.Name,
		&user.Age,
		&user.Job,
		&user.Bio,
		&user.Distance,
		&interestsRaw,
		&birthDate,
		&user.Country,
		&user.Prefecture,
		&user.DatingReason,
		&user.PointBalance,
		&createdAt,
		&lastLoginAt,
		&updatedAt,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return domain.User{}, err
		}
		return domain.User{}, fmt.Errorf("scan user: %w", err)
	}

	if interestsRaw.Valid {
		user.Interests, err = parseTextArray(interestsRaw.String)
		if err != nil {
			return domain.User{}, fmt.Errorf("parse user interests: %w", err)
		}
	} else {
		user.Interests = []string{}
	}

	user.CreatedAt = createdAt.Format(time.RFC3339)
	if lastLoginAt.Valid {
		user.LastLoginAt = lastLoginAt.Time.Format(time.RFC3339)
	}
	user.UpdatedAt = updatedAt.Format(time.RFC3339)
	user.BirthDate = birthDate.Format("2006-01-02")
	return user, nil
}
