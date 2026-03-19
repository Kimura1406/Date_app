CREATE TABLE IF NOT EXISTS banners (
    id TEXT PRIMARY KEY,
    image_url TEXT NOT NULL DEFAULT '',
    event_name TEXT NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 0,
    redirect_link TEXT NOT NULL DEFAULT '',
    published BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT banners_event_name_length_check CHECK (char_length(event_name) <= 100)
);

CREATE INDEX IF NOT EXISTS idx_banners_display_order ON banners (display_order ASC, created_at DESC);
