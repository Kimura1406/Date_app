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
		SELECT id, email, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason, created_at, updated_at
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
		SELECT id, email, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason, created_at, updated_at
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

type userScanner interface {
	Scan(dest ...any) error
}

func scanUser(scanner userScanner) (domain.User, error) {
	var user domain.User
	var createdAt time.Time
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
		&createdAt,
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
	user.UpdatedAt = updatedAt.Format(time.RFC3339)
	user.BirthDate = birthDate.Format("2006-01-02")
	return user, nil
}
