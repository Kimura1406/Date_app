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
		`INSERT INTO profiles (id, name, age, job, bio, distance, interests, country, gender, location, image_url, is_new)
		 VALUES
			('p-001', 'Samantha', 26, 'Photographer', 'Coffee first, road trips second, great conversations always.', '3 km from you', ARRAY['Travel', 'Film', 'Brunch'], 'Vietnam', 'female', 'Ho Chi Minh City', 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80', true),
			('p-002', 'Mary', 27, 'Fitness Coach', 'Looking for a kind person who loves staying active and trying new cafes.', '1 km from you', ARRAY['Workout', 'Travel', 'Coffee'], 'Thailand', 'female', 'Bangkok', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=900&q=80', true),
			('p-003', 'Dakota', 30, 'Designer', 'Big on design, city walks, and quiet Sunday brunches.', '11 km from you', ARRAY['Design', 'Books', 'Fashion'], 'England', 'female', 'London', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80', false),
			('p-004', 'Vi', 24, 'Marketing Specialist', 'Looking for warm conversations and someone who enjoys spontaneous trips.', '8 km from you', ARRAY['Music', 'Travel', 'Photo'], 'Vietnam', 'female', 'Da Nang', 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=900&q=80', true),
			('p-005', 'Yuna', 25, 'Product Manager', 'I enjoy thoughtful chats, beautiful spaces, and ramen after work.', '6 km from you', ARRAY['Product', 'Food', 'Art'], 'Japan', 'female', 'Tokyo', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80', false),
			('p-006', 'Elena', 29, 'Doctor', 'Looking for honesty, kindness, and someone who loves the sea.', '14 km from you', ARRAY['Wellness', 'Beach', 'Cooking'], 'Russia', 'female', 'Moscow', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=900&q=80', false),
			('p-007', 'Minji', 28, 'Software Engineer', 'I like building things, deep talks, and late-night desserts.', '4 km from you', ARRAY['Coding', 'Dessert', 'Movies'], 'Korea', 'female', 'Seoul', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=900&q=80', true),
			('p-008', 'Lin', 26, 'Teacher', 'Calm energy, good books, and long walks are my comfort zone.', '9 km from you', ARRAY['Reading', 'Tea', 'Nature'], 'China', 'female', 'Shanghai', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=900&q=80', false)
		 ON CONFLICT (id) DO UPDATE SET
			name = EXCLUDED.name,
			age = EXCLUDED.age,
			job = EXCLUDED.job,
			bio = EXCLUDED.bio,
			distance = EXCLUDED.distance,
			interests = EXCLUDED.interests,
			country = EXCLUDED.country,
			gender = EXCLUDED.gender,
			location = EXCLUDED.location,
			image_url = EXCLUDED.image_url,
			is_new = EXCLUDED.is_new`,
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
		INSERT INTO users (id, email, password_hash, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		ON CONFLICT (email) DO UPDATE SET
			role = EXCLUDED.role,
			birth_date = EXCLUDED.birth_date,
			country = EXCLUDED.country,
			prefecture = EXCLUDED.prefecture,
			dating_reason = EXCLUDED.dating_reason
	`,
		"281LINAQ",
		"lina@example.com",
		string(passwordHash),
		"user",
		"Lina",
		24,
		"Photographer",
		"Coffee first, road trips second, great conversations always.",
		"2 km away",
		[]string{"Travel", "Film", "Brunch"},
		"2001-04-18",
		"Japan",
		"Tokyo",
		"Long-term relationship with honest communication.",
	); err != nil {
		return fmt.Errorf("seed users: %w", err)
	}

	if _, err := db.ExecContext(ctx, `
		INSERT INTO users (id, email, password_hash, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		ON CONFLICT (email) DO UPDATE SET
			role = EXCLUDED.role,
			birth_date = EXCLUDED.birth_date,
			country = EXCLUDED.country,
			prefecture = EXCLUDED.prefecture,
			dating_reason = EXCLUDED.dating_reason
	`,
		"472MARYA",
		"mary@example.com",
		string(passwordHash),
		"user",
		"Mary",
		27,
		"Fitness Coach",
		"Looking for a kind person who loves staying active and trying new cafes.",
		"1 km away",
		[]string{"Workout", "Travel", "Coffee"},
		"1998-07-22",
		"Thailand",
		"Bangkok",
		"Meet new people and see where the connection goes.",
	); err != nil {
		return fmt.Errorf("seed users: %w", err)
	}

	adminPasswordHash, err := bcrypt.GenerateFromPassword([]byte("admin12345"), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("hash seed admin password: %w", err)
	}

	if _, err := db.ExecContext(ctx, `
		INSERT INTO users (id, email, password_hash, role, name, age, job, bio, distance, interests, birth_date, country, prefecture, dating_reason)
		VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
		ON CONFLICT (email) DO UPDATE SET
			role = EXCLUDED.role,
			birth_date = EXCLUDED.birth_date,
			country = EXCLUDED.country,
			prefecture = EXCLUDED.prefecture,
			dating_reason = EXCLUDED.dating_reason
	`,
		"913ADMIN",
		"admin@kimura.local",
		string(adminPasswordHash),
		"admin",
		"Kimura Admin",
		30,
		"Operations",
		"Platform administrator",
		"HQ",
		[]string{"Moderation", "Safety", "Growth"},
		"1995-08-09",
		"Japan",
		"Osaka",
		"Admin account for moderation and customer support.",
	); err != nil {
		return fmt.Errorf("seed admin user: %w", err)
	}

	if _, err := db.ExecContext(ctx, `
		INSERT INTO chat_rooms (id, room_type, user_one_id, user_two_id)
		VALUES
			('admin-281LINAQ-913ADMIN', 'admin', LEAST('281LINAQ', '913ADMIN'), GREATEST('281LINAQ', '913ADMIN')),
			('admin-472MARYA-913ADMIN', 'admin', LEAST('472MARYA', '913ADMIN'), GREATEST('472MARYA', '913ADMIN')),
			('user-281LINAQ-472MARYA', 'user', LEAST('281LINAQ', '472MARYA'), GREATEST('281LINAQ', '472MARYA'))
		ON CONFLICT DO NOTHING
	`); err != nil {
		return fmt.Errorf("seed chat rooms: %w", err)
	}

	if _, err := db.ExecContext(ctx, `
		INSERT INTO chat_messages (id, room_id, sender_user_id, body, created_at)
		VALUES
			('msg_seed_001', 'admin-281LINAQ-913ADMIN', '281LINAQ', 'サポートに相談したいことがあります。', NOW() - INTERVAL '40 minutes'),
			('msg_seed_002', 'admin-281LINAQ-913ADMIN', '913ADMIN', 'もちろんです。ご不明点を教えてください。', NOW() - INTERVAL '36 minutes'),
			('msg_seed_003', 'admin-472MARYA-913ADMIN', '472MARYA', '登録できたので、まずは使い方を知りたいです。', NOW() - INTERVAL '28 minutes'),
			('msg_seed_004', 'admin-472MARYA-913ADMIN', '913ADMIN', 'プロフィール設定から始めるのがおすすめです。', NOW() - INTERVAL '21 minutes'),
			('msg_seed_005', 'user-281LINAQ-472MARYA', '281LINAQ', '週末に新しいカフェへ行ってみない？', NOW() - INTERVAL '18 minutes'),
			('msg_seed_006', 'user-281LINAQ-472MARYA', '472MARYA', 'いいね、午後なら時間あるよ。', NOW() - INTERVAL '12 minutes')
		ON CONFLICT DO NOTHING
	`); err != nil {
		return fmt.Errorf("seed chat messages: %w", err)
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
