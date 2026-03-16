package database

import (
	"context"
	"database/sql"
	"embed"
	"fmt"
	"sort"
	"time"

	"golang.org/x/crypto/bcrypt"
)

//go:embed migrations/*.sql
var migrationFiles embed.FS

func Migrate(db *sql.DB) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if _, err := db.ExecContext(ctx, `
		CREATE TABLE IF NOT EXISTS schema_migrations (
			version TEXT PRIMARY KEY,
			applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
		)
	`); err != nil {
		return fmt.Errorf("create schema_migrations: %w", err)
	}

	entries, err := migrationFiles.ReadDir("migrations")
	if err != nil {
		return fmt.Errorf("read migrations: %w", err)
	}

	names := make([]string, 0, len(entries))
	for _, entry := range entries {
		if !entry.IsDir() {
			names = append(names, entry.Name())
		}
	}
	sort.Strings(names)

	for _, name := range names {
		applied, err := migrationApplied(ctx, db, name)
		if err != nil {
			return err
		}
		if applied {
			continue
		}

		sqlBytes, err := migrationFiles.ReadFile("migrations/" + name)
		if err != nil {
			return fmt.Errorf("read migration %s: %w", name, err)
		}

		tx, err := db.BeginTx(ctx, nil)
		if err != nil {
			return fmt.Errorf("begin migration %s: %w", name, err)
		}

		if _, err := tx.ExecContext(ctx, string(sqlBytes)); err != nil {
			_ = tx.Rollback()
			return fmt.Errorf("apply migration %s: %w", name, err)
		}

		if _, err := tx.ExecContext(ctx, `INSERT INTO schema_migrations(version) VALUES ($1)`, name); err != nil {
			_ = tx.Rollback()
			return fmt.Errorf("record migration %s: %w", name, err)
		}

		if err := tx.Commit(); err != nil {
			return fmt.Errorf("commit migration %s: %w", name, err)
		}
	}

	return nil
}

func Seed(db *sql.DB) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	seedStatements := []string{
		`INSERT INTO profiles (id, name, age, job, bio, distance, interests)
		 VALUES
			('p-001', 'Lina', 24, 'Photographer', 'Coffee first, road trips second, great conversations always.', '2 km away', ARRAY['Travel', 'Film', 'Brunch']),
			('p-002', 'Mai', 27, 'UX Designer', 'Looking for someone kind, curious, and up for late-night noodles.', '5 km away', ARRAY['Design', 'Music', 'Cats'])
		 ON CONFLICT (id) DO NOTHING`,
		`INSERT INTO matches (id, name, last_message, last_seen, status)
		 VALUES
			('m-001', 'Ava', 'Dinner this weekend?', '2m ago', 'new'),
			('m-002', 'Noah', 'Send me your playlist', '10m ago', 'active')
		 ON CONFLICT (id) DO NOTHING`,
	}

	for _, stmt := range seedStatements {
		if _, err := db.ExecContext(ctx, stmt); err != nil {
			return fmt.Errorf("seed database: %w", err)
		}
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("hash seed user password: %w", err)
	}

	if _, err := db.ExecContext(ctx, `
		INSERT INTO users (id, email, password_hash, role, name, age, job, bio, distance, interests)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		ON CONFLICT (email) DO UPDATE SET role = EXCLUDED.role
	`,
		"usr_seed_001",
		"lina@example.com",
		string(passwordHash),
		"user",
		"Lina",
		24,
		"Photographer",
		"Coffee first, road trips second, great conversations always.",
		"2 km away",
		[]string{"Travel", "Film", "Brunch"},
	); err != nil {
		return fmt.Errorf("seed users: %w", err)
	}

	adminPasswordHash, err := bcrypt.GenerateFromPassword([]byte("admin12345"), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("hash seed admin password: %w", err)
	}

	if _, err := db.ExecContext(ctx, `
		INSERT INTO users (id, email, password_hash, role, name, age, job, bio, distance, interests)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
		ON CONFLICT (email) DO UPDATE SET role = EXCLUDED.role
	`,
		"adm_seed_001",
		"admin@kimura.local",
		string(adminPasswordHash),
		"admin",
		"Kimura Admin",
		30,
		"Operations",
		"Platform administrator",
		"HQ",
		[]string{"Moderation", "Safety", "Growth"},
	); err != nil {
		return fmt.Errorf("seed admin user: %w", err)
	}

	return nil
}

func migrationApplied(ctx context.Context, db *sql.DB, version string) (bool, error) {
	var exists bool
	err := db.QueryRowContext(ctx, `SELECT EXISTS(SELECT 1 FROM schema_migrations WHERE version = $1)`, version).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("check migration %s: %w", version, err)
	}
	return exists, nil
}
