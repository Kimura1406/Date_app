CREATE TABLE IF NOT EXISTS notifications (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    actor_user_id TEXT REFERENCES users(id) ON DELETE SET NULL,
    room_id TEXT REFERENCES chat_rooms(id) ON DELETE CASCADE,
    room_type TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created_at
    ON notifications(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_user_type_created_at
    ON notifications(user_id, type, created_at DESC);

INSERT INTO notifications (id, user_id, type, message, created_at)
SELECT
    'welcome_' || u.id,
    u.id,
    'welcome',
    'Xin chào, mình là Dating admin. Rất mong bạn có những trải nghiệm tuyệt vời và sớm tìm được người đồng hành nhé.',
    u.created_at
FROM users u
WHERE u.role = 'user'
  AND NOT EXISTS (
      SELECT 1
      FROM notifications n
      WHERE n.user_id = u.id
        AND n.type = 'welcome'
  );
