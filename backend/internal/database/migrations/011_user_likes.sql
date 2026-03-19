CREATE TABLE IF NOT EXISTS user_likes (
    target_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    liker_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (target_user_id, liker_user_id),
    CONSTRAINT user_likes_no_self_like CHECK (target_user_id <> liker_user_id)
);

CREATE INDEX IF NOT EXISTS idx_user_likes_liker_user_id
    ON user_likes (liker_user_id);
