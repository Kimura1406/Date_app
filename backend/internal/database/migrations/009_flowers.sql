CREATE TABLE IF NOT EXISTS flowers (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    image_url TEXT NOT NULL DEFAULT '',
    description TEXT NOT NULL DEFAULT '',
    price_points INTEGER NOT NULL DEFAULT 1,
    purchaser_count INTEGER NOT NULL DEFAULT 0,
    purchase_count INTEGER NOT NULL DEFAULT 0,
    published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT flowers_price_points_check CHECK (price_points > 0),
    CONSTRAINT flowers_name_length_check CHECK (char_length(name) <= 50),
    CONSTRAINT flowers_description_length_check CHECK (char_length(description) <= 100)
);

CREATE INDEX IF NOT EXISTS idx_flowers_created_at ON flowers (created_at DESC);
