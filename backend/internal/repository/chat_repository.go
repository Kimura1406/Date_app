package repository

import (
	"context"
	"crypto/rand"
	"database/sql"
	"fmt"
	"strings"
	"time"

	"github.com/kimura/dating/backend/internal/domain"
)

type ChatRepository struct {
	db *sql.DB
}

func NewChatRepository(db *sql.DB) *ChatRepository {
	return &ChatRepository{db: db}
}

func (r *ChatRepository) EnsureAdminRoomForUser(ctx context.Context, userID string) error {
	var adminID string
	err := r.db.QueryRowContext(ctx, `
		SELECT id
		FROM users
		WHERE role = 'admin'
		ORDER BY created_at ASC
		LIMIT 1
	`).Scan(&adminID)
	if err != nil {
		return fmt.Errorf("find admin user: %w", err)
	}

	if adminID == userID {
		return nil
	}

	roomID := buildDeterministicRoomID("admin", adminID, userID)
	_, err = r.db.ExecContext(ctx, `
		INSERT INTO chat_rooms (id, room_type, user_one_id, user_two_id)
		VALUES ($1, 'admin', LEAST($2, $3), GREATEST($2, $3))
		ON CONFLICT DO NOTHING
	`, roomID, adminID, userID)
	if err != nil {
		return fmt.Errorf("ensure admin room: %w", err)
	}

	return nil
}

func (r *ChatRepository) GetAdminRoomIDForUser(ctx context.Context, userID string) (string, error) {
	var adminID string
	err := r.db.QueryRowContext(ctx, `
		SELECT id
		FROM users
		WHERE role = 'admin'
		ORDER BY created_at ASC
		LIMIT 1
	`).Scan(&adminID)
	if err != nil {
		return "", fmt.Errorf("find admin user: %w", err)
	}

	if adminID == userID {
		return "", sql.ErrNoRows
	}

	return buildDeterministicRoomID("admin", adminID, userID), nil
}

func (r *ChatRepository) EnsureDirectRoomForUsers(ctx context.Context, firstUserID, secondUserID string) error {
	if firstUserID == secondUserID {
		return nil
	}

	roomID := buildDeterministicRoomID("user", firstUserID, secondUserID)
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO chat_rooms (id, room_type, user_one_id, user_two_id)
		VALUES ($1, 'user', LEAST($2, $3), GREATEST($2, $3))
		ON CONFLICT DO NOTHING
	`, roomID, firstUserID, secondUserID)
	if err != nil {
		return fmt.Errorf("ensure direct room: %w", err)
	}

	return nil
}

func (r *ChatRepository) GetDirectRoomIDForUsers(ctx context.Context, firstUserID, secondUserID string) (string, error) {
	if firstUserID == secondUserID {
		return "", sql.ErrNoRows
	}

	return buildDeterministicRoomID("user", firstUserID, secondUserID), nil
}

func (r *ChatRepository) ListRooms(ctx context.Context, roomType string) ([]domain.ChatRoomSummary, error) {
	return r.listRoomsByQuery(ctx, `
		SELECT
			cr.id,
			cr.room_type,
			u1.id,
			u1.name,
			u1.role,
			u2.id,
			u2.name,
			u2.role,
			COALESCE(last_msg.body, ''),
			COALESCE(last_msg.created_at, cr.created_at),
			0
		FROM chat_rooms cr
		JOIN users u1 ON u1.id = cr.user_one_id
		JOIN users u2 ON u2.id = cr.user_two_id
		LEFT JOIN LATERAL (
			SELECT cm.body, cm.created_at
			FROM chat_messages cm
			WHERE cm.room_id = cr.id
			ORDER BY cm.created_at DESC
			LIMIT 1
		) last_msg ON true
		WHERE cr.room_type = $1
		ORDER BY COALESCE(last_msg.created_at, cr.created_at) DESC, cr.id DESC
	`, roomType)
}

func (r *ChatRepository) ListRoomsForUser(ctx context.Context, userID, roomType string) ([]domain.ChatRoomSummary, error) {
	return r.listRoomsByQuery(ctx, `
		SELECT
			cr.id,
			cr.room_type,
			u1.id,
			u1.name,
			u1.role,
			u2.id,
			u2.name,
			u2.role,
			COALESCE(last_msg.body, ''),
			COALESCE(last_msg.created_at, cr.created_at),
			COALESCE(unread.unread_count, 0)
		FROM chat_rooms cr
		JOIN users u1 ON u1.id = cr.user_one_id
		JOIN users u2 ON u2.id = cr.user_two_id
		LEFT JOIN LATERAL (
			SELECT cm.body, cm.created_at
			FROM chat_messages cm
			WHERE cm.room_id = cr.id
			ORDER BY cm.created_at DESC
			LIMIT 1
		) last_msg ON true
		LEFT JOIN LATERAL (
			SELECT COUNT(*)::INT AS unread_count
			FROM chat_messages cm
			LEFT JOIN chat_room_reads crr
				ON crr.room_id = cr.id
			   AND crr.user_id = $2
			WHERE cm.room_id = cr.id
			  AND cm.sender_user_id <> $2
			  AND cm.created_at > COALESCE(crr.last_read_at, TO_TIMESTAMP(0))
		) unread ON true
		WHERE cr.room_type = $1
		  AND (cr.user_one_id = $2 OR cr.user_two_id = $2)
		ORDER BY COALESCE(last_msg.created_at, cr.created_at) DESC, cr.id DESC
	`, roomType, userID)
}

func (r *ChatRepository) listRoomsByQuery(ctx context.Context, query string, args ...any) ([]domain.ChatRoomSummary, error) {
	rows, err := r.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, fmt.Errorf("list chat rooms: %w", err)
	}
	defer rows.Close()

	rooms := make([]domain.ChatRoomSummary, 0)
	for rows.Next() {
		var room domain.ChatRoomSummary
		var first domain.ChatParticipant
		var second domain.ChatParticipant
		var lastAt time.Time
		var unreadCount int

		if err := rows.Scan(
			&room.RoomID,
			&room.RoomType,
			&first.UserID,
			&first.Name,
			&first.Role,
			&second.UserID,
			&second.Name,
			&second.Role,
			&room.LastMessage,
			&lastAt,
			&unreadCount,
		); err != nil {
			return nil, fmt.Errorf("scan chat room: %w", err)
		}

		room.LastMessageAt = lastAt.Format(time.RFC3339)
		room.UnreadCount = unreadCount
		room.Participants = []domain.ChatParticipant{first, second}
		rooms = append(rooms, room)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate chat rooms: %w", err)
	}

	return rooms, nil
}

func (r *ChatRepository) GetRoomDetail(ctx context.Context, roomID string) (domain.ChatRoomDetail, error) {
	var detail domain.ChatRoomDetail
	var first domain.ChatParticipant
	var second domain.ChatParticipant

	err := r.db.QueryRowContext(ctx, `
		SELECT
			cr.id,
			cr.room_type,
			u1.id,
			u1.name,
			u1.role,
			u2.id,
			u2.name,
			u2.role
		FROM chat_rooms cr
		JOIN users u1 ON u1.id = cr.user_one_id
		JOIN users u2 ON u2.id = cr.user_two_id
		WHERE cr.id = $1
	`, roomID).Scan(
		&detail.RoomID,
		&detail.RoomType,
		&first.UserID,
		&first.Name,
		&first.Role,
		&second.UserID,
		&second.Name,
		&second.Role,
	)
	if err != nil {
		if err == sql.ErrNoRows {
			return domain.ChatRoomDetail{}, err
		}
		return domain.ChatRoomDetail{}, fmt.Errorf("get chat room: %w", err)
	}

	detail.Participants = []domain.ChatParticipant{first, second}

	rows, err := r.db.QueryContext(ctx, `
		SELECT
			cm.id,
			cm.room_id,
			cm.sender_user_id,
			u.name,
			u.role,
			cm.body,
			cm.created_at
		FROM chat_messages cm
		JOIN users u ON u.id = cm.sender_user_id
		WHERE cm.room_id = $1
		ORDER BY cm.created_at ASC, cm.id ASC
	`, roomID)
	if err != nil {
		return domain.ChatRoomDetail{}, fmt.Errorf("query chat messages: %w", err)
	}
	defer rows.Close()

	messages := make([]domain.ChatMessage, 0)
	for rows.Next() {
		var message domain.ChatMessage
		var participant domain.ChatParticipant
		var createdAt time.Time
		if err := rows.Scan(
			&message.ID,
			&message.RoomID,
			&message.SenderID,
			&message.SenderName,
			&participant.Role,
			&message.Body,
			&createdAt,
		); err != nil {
			return domain.ChatRoomDetail{}, fmt.Errorf("scan chat message: %w", err)
		}
		participant.UserID = message.SenderID
		participant.Name = message.SenderName
		message.Participant = participant
		message.SentAt = createdAt.Format(time.RFC3339)
		messages = append(messages, message)
	}

	if err := rows.Err(); err != nil {
		return domain.ChatRoomDetail{}, fmt.Errorf("iterate chat messages: %w", err)
	}

	detail.Messages = messages
	return detail, nil
}

func (r *ChatRepository) CreateMessage(ctx context.Context, roomID, senderUserID, body string) (domain.ChatMessage, error) {
	messageID := buildChatMessageID()
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO chat_messages (id, room_id, sender_user_id, body)
		VALUES ($1, $2, $3, $4)
	`, messageID, roomID, senderUserID, body)
	if err != nil {
		return domain.ChatMessage{}, fmt.Errorf("create chat message: %w", err)
	}

	var message domain.ChatMessage
	var participant domain.ChatParticipant
	var createdAt time.Time
	err = r.db.QueryRowContext(ctx, `
		SELECT
			cm.id,
			cm.room_id,
			cm.sender_user_id,
			u.name,
			u.role,
			cm.body,
			cm.created_at
		FROM chat_messages cm
		JOIN users u ON u.id = cm.sender_user_id
		WHERE cm.id = $1
	`, messageID).Scan(
		&message.ID,
		&message.RoomID,
		&message.SenderID,
		&message.SenderName,
		&participant.Role,
		&message.Body,
		&createdAt,
	)
	if err != nil {
		return domain.ChatMessage{}, fmt.Errorf("reload chat message: %w", err)
	}

	participant.UserID = message.SenderID
	participant.Name = message.SenderName
	message.Participant = participant
	message.SentAt = createdAt.Format(time.RFC3339)

	if _, err := r.db.ExecContext(ctx, `
		UPDATE chat_rooms
		SET updated_at = NOW()
		WHERE id = $1
	`, roomID); err != nil {
		return domain.ChatMessage{}, fmt.Errorf("touch chat room: %w", err)
	}

	if err := r.createMessageNotification(ctx, roomID, message); err != nil {
		return domain.ChatMessage{}, err
	}

	return message, nil
}

func (r *ChatRepository) createMessageNotification(ctx context.Context, roomID string, message domain.ChatMessage) error {
	var (
		roomType  string
		userOneID string
		userTwoID string
	)
	if err := r.db.QueryRowContext(ctx, `
		SELECT room_type, user_one_id, user_two_id
		FROM chat_rooms
		WHERE id = $1
	`, roomID).Scan(&roomType, &userOneID, &userTwoID); err != nil {
		return fmt.Errorf("load chat room for notification: %w", err)
	}

	recipientUserID := userOneID
	if recipientUserID == message.SenderID {
		recipientUserID = userTwoID
	}
	if recipientUserID == "" || recipientUserID == message.SenderID {
		return nil
	}

	var (
		notificationType string
		notificationBody string
	)
	switch {
	case roomType == "user":
		notificationType = "user_message"
		notificationBody = fmt.Sprintf("%s đã gửi tin nhắn cho bạn.", message.SenderName)
	case roomType == "admin" && message.Participant.Role == "admin":
		notificationType = "admin_message"
		notificationBody = "Bạn nhận được tin nhắn từ admin."
	default:
		return nil
	}

	notificationID := "ntf_" + generateRepositoryHexID(16)
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO notifications (id, user_id, type, message, actor_user_id, room_id, room_type, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
	`, notificationID, recipientUserID, notificationType, notificationBody, message.SenderID, roomID, roomType)
	if err != nil {
		return fmt.Errorf("insert message notification: %w", err)
	}

	return nil
}

func (r *ChatRepository) IsParticipant(ctx context.Context, roomID, userID string) (bool, error) {
	var exists bool
	err := r.db.QueryRowContext(ctx, `
		SELECT EXISTS(
			SELECT 1
			FROM chat_rooms
			WHERE id = $1 AND (user_one_id = $2 OR user_two_id = $2)
		)
	`, roomID, userID).Scan(&exists)
	if err != nil {
		return false, fmt.Errorf("check chat participant: %w", err)
	}
	return exists, nil
}

func (r *ChatRepository) MarkRoomRead(ctx context.Context, roomID, userID string) error {
	_, err := r.db.ExecContext(ctx, `
		INSERT INTO chat_room_reads (room_id, user_id, last_read_at)
		VALUES ($1, $2, NOW())
		ON CONFLICT (room_id, user_id)
		DO UPDATE SET last_read_at = GREATEST(chat_room_reads.last_read_at, EXCLUDED.last_read_at)
	`, roomID, userID)
	if err != nil {
		return fmt.Errorf("mark room read: %w", err)
	}
	return nil
}

func buildDeterministicRoomID(roomType, first, second string) string {
	if first > second {
		first, second = second, first
	}
	return fmt.Sprintf("%s-%s-%s", roomType, first, second)
}

func buildChatMessageID() string {
	return "msg_" + generateRepositoryHexID(12)
}

func generateRepositoryHexID(size int) string {
	bytes := make([]byte, size/2)
	if _, err := rand.Read(bytes); err != nil {
		return "fallbackchatid"
	}

	const hexdigits = "0123456789abcdef"
	var builder strings.Builder
	builder.Grow(len(bytes) * 2)
	for _, value := range bytes {
		builder.WriteByte(hexdigits[value>>4])
		builder.WriteByte(hexdigits[value&0x0f])
	}
	return builder.String()
}
