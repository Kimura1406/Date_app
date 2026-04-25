package service

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"strings"

	"github.com/kimura/dating/backend/internal/domain"
)

var ErrForbiddenChatRoom = errors.New("forbidden chat room")

type chatRepository interface {
	EnsureAdminRoomForUser(ctx context.Context, userID string) error
	GetAdminRoomIDForUser(ctx context.Context, userID string) (string, error)
	EnsureDirectRoomForUsers(ctx context.Context, firstUserID, secondUserID string) error
	GetDirectRoomIDForUsers(ctx context.Context, firstUserID, secondUserID string) (string, error)
	ListRooms(ctx context.Context, roomType string) ([]domain.ChatRoomSummary, error)
	ListRoomsForUser(ctx context.Context, userID, roomType string) ([]domain.ChatRoomSummary, error)
	GetRoomDetail(ctx context.Context, roomID string) (domain.ChatRoomDetail, error)
	CreateMessage(ctx context.Context, roomID, senderUserID, body string) (domain.ChatMessage, error)
	IsParticipant(ctx context.Context, roomID, userID string) (bool, error)
	MarkRoomRead(ctx context.Context, roomID, userID string) error
}

type ChatService struct {
	repo chatRepository
}

func NewChatService(repo chatRepository) *ChatService {
	return &ChatService{repo: repo}
}

func (s *ChatService) EnsureAdminRoomForUser(ctx context.Context, userID string) error {
	return s.repo.EnsureAdminRoomForUser(ctx, userID)
}

func (s *ChatService) EnsureAndGetAdminRoom(ctx context.Context, userID string) (domain.ChatRoomDetail, error) {
	if err := s.repo.EnsureAdminRoomForUser(ctx, userID); err != nil {
		return domain.ChatRoomDetail{}, err
	}

	roomID, err := s.repo.GetAdminRoomIDForUser(ctx, userID)
	if err != nil {
		return domain.ChatRoomDetail{}, err
	}

	detail, err := s.repo.GetRoomDetail(ctx, roomID)
	if err != nil {
		return domain.ChatRoomDetail{}, err
	}
	if err := s.repo.MarkRoomRead(ctx, roomID, userID); err != nil {
		return domain.ChatRoomDetail{}, err
	}
	return detail, nil
}

func (s *ChatService) EnsureAndGetDirectRoom(ctx context.Context, requesterUserID, targetUserID string) (domain.ChatRoomDetail, error) {
	if requesterUserID == "" || targetUserID == "" || requesterUserID == targetUserID {
		return domain.ChatRoomDetail{}, fmt.Errorf("invalid direct chat participants")
	}

	if err := s.repo.EnsureDirectRoomForUsers(ctx, requesterUserID, targetUserID); err != nil {
		return domain.ChatRoomDetail{}, err
	}

	roomID, err := s.repo.GetDirectRoomIDForUsers(ctx, requesterUserID, targetUserID)
	if err != nil {
		return domain.ChatRoomDetail{}, err
	}

	detail, err := s.repo.GetRoomDetail(ctx, roomID)
	if err != nil {
		return domain.ChatRoomDetail{}, err
	}
	if err := s.repo.MarkRoomRead(ctx, roomID, requesterUserID); err != nil {
		return domain.ChatRoomDetail{}, err
	}
	return detail, nil
}

func (s *ChatService) ListRooms(ctx context.Context, roomType string) ([]domain.ChatRoomSummary, error) {
	if roomType != "user" && roomType != "admin" {
		return nil, fmt.Errorf("room type must be user or admin")
	}
	return s.repo.ListRooms(ctx, roomType)
}

func (s *ChatService) ListRoomsForUser(ctx context.Context, userID, roomType string) ([]domain.ChatRoomSummary, error) {
	if roomType != "user" && roomType != "admin" {
		return nil, fmt.Errorf("room type must be user or admin")
	}
	return s.repo.ListRoomsForUser(ctx, userID, roomType)
}

func (s *ChatService) GetRoomDetail(ctx context.Context, roomID, requesterUserID, requesterRole string) (domain.ChatRoomDetail, error) {
	if requesterRole != "admin" {
		ok, err := s.repo.IsParticipant(ctx, roomID, requesterUserID)
		if err != nil {
			return domain.ChatRoomDetail{}, err
		}
		if !ok {
			return domain.ChatRoomDetail{}, ErrForbiddenChatRoom
		}
	}

	detail, err := s.repo.GetRoomDetail(ctx, roomID)
	if err != nil {
		return domain.ChatRoomDetail{}, err
	}
	if requesterUserID != "" {
		if err := s.repo.MarkRoomRead(ctx, roomID, requesterUserID); err != nil {
			return domain.ChatRoomDetail{}, err
		}
	}
	return detail, nil
}

func (s *ChatService) CreateMessage(ctx context.Context, roomID, senderUserID, senderRole string, input domain.CreateChatMessageInput) (domain.ChatMessage, error) {
	body := strings.TrimSpace(input.Body)
	if body == "" {
		return domain.ChatMessage{}, fmt.Errorf("message body is required")
	}

	if senderRole != "admin" {
		ok, err := s.repo.IsParticipant(ctx, roomID, senderUserID)
		if err != nil {
			return domain.ChatMessage{}, err
		}
		if !ok {
			return domain.ChatMessage{}, ErrForbiddenChatRoom
		}
	}

	message, err := s.repo.CreateMessage(ctx, roomID, senderUserID, body)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return domain.ChatMessage{}, err
		}
		return domain.ChatMessage{}, err
	}

	return message, nil
}
