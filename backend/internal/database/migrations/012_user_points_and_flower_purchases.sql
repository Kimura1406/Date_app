ALTER TABLE users
    ADD COLUMN IF NOT EXISTS point_balance INTEGER NOT NULL DEFAULT 10;

CREATE TABLE IF NOT EXISTS flower_purchases (
    id BIGSERIAL PRIMARY KEY,
    flower_id TEXT NOT NULL REFERENCES flowers(id) ON DELETE CASCADE,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    price_points INTEGER NOT NULL,
    purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_flower_purchases_flower_id
    ON flower_purchases (flower_id);

CREATE INDEX IF NOT EXISTS idx_flower_purchases_user_id
    ON flower_purchases (user_id);
