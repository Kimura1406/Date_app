CREATE TABLE IF NOT EXISTS chat_rooms (
    id TEXT PRIMARY KEY,
    room_type TEXT NOT NULL,
    user_one_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_two_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chat_rooms_distinct_users CHECK (user_one_id <> user_two_id),
    CONSTRAINT chat_rooms_type_check CHECK (room_type IN ('user', 'admin'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_chat_rooms_unique_pair
    ON chat_rooms (
        room_type,
        LEAST(user_one_id, user_two_id),
        GREATEST(user_one_id, user_two_id)
    );

CREATE TABLE IF NOT EXISTS chat_messages (
    id TEXT PRIMARY KEY,
    room_id TEXT NOT NULL REFERENCES chat_rooms(id) ON DELETE CASCADE,
    sender_user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_room_created
    ON chat_messages (room_id, created_at DESC);
