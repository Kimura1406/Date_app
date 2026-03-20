CREATE TABLE IF NOT EXISTS user_blocks (
    blocked_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocker_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (blocked_user_id, blocker_user_id),
    CONSTRAINT user_blocks_no_self_block CHECK (blocked_user_id <> blocker_user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker_user_id
    ON user_blocks (blocker_user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS user_reports (
    id BIGSERIAL PRIMARY KEY,
    reported_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reporter_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT user_reports_no_self_report CHECK (reported_user_id <> reporter_user_id),
    CONSTRAINT user_reports_reason_length_check CHECK (char_length(reason) <= 100)
);

CREATE INDEX IF NOT EXISTS idx_user_reports_reported_user_id
    ON user_reports (reported_user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_reports_reporter_user_id
    ON user_reports (reporter_user_id, created_at DESC);
