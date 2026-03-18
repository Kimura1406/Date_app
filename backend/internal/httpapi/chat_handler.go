package httpapi

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"

	"github.com/kimura/dating/backend/internal/domain"
	"github.com/kimura/dating/backend/internal/service"
)

type ChatHandler struct {
	chatService *service.ChatService
}

func NewChatHandler(chatService *service.ChatService) *ChatHandler {
	return &ChatHandler{chatService: chatService}
}

func (h *ChatHandler) ListAdminRooms(w http.ResponseWriter, r *http.Request) {
	roomType := r.URL.Query().Get("type")
	if roomType == "" {
		roomType = "user"
	}

	items, err := h.chatService.ListRooms(r.Context(), roomType)
	if err != nil {
		writeDomainError(w, err, "failed to load chat rooms")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *ChatHandler) ListUserRooms(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	roomType := r.URL.Query().Get("type")
	if roomType == "" {
		roomType = "admin"
	}

	items, err := h.chatService.ListRoomsForUser(r.Context(), claims.Subject, roomType)
	if err != nil {
		writeDomainError(w, err, "failed to load chat rooms")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *ChatHandler) EnsureAdminRoomForUser(w http.ResponseWriter, r *http.Request) {
	room, err := h.chatService.EnsureAndGetAdminRoom(r.Context(), r.PathValue("id"))
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			writeError(w, http.StatusNotFound, "chat room not found")
		default:
			writeDomainError(w, err, "failed to ensure chat room")
		}
		return
	}

	writeJSON(w, http.StatusOK, room)
}

func (h *ChatHandler) GetRoomDetail(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	room, err := h.chatService.GetRoomDetail(r.Context(), r.PathValue("id"), claims.Subject, claims.Role)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			writeError(w, http.StatusNotFound, "chat room not found")
		case errors.Is(err, service.ErrForbiddenChatRoom):
			writeError(w, http.StatusForbidden, "forbidden")
		default:
			writeDomainError(w, err, "failed to load chat room")
		}
		return
	}

	writeJSON(w, http.StatusOK, room)
}

func (h *ChatHandler) CreateMessage(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	var input domain.CreateChatMessageInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	message, err := h.chatService.CreateMessage(r.Context(), r.PathValue("id"), claims.Subject, claims.Role, input)
	if err != nil {
		switch {
		case errors.Is(err, sql.ErrNoRows):
			writeError(w, http.StatusNotFound, "chat room not found")
		case errors.Is(err, service.ErrForbiddenChatRoom):
			writeError(w, http.StatusForbidden, "forbidden")
		default:
			writeDomainError(w, err, "failed to send message")
		}
		return
	}

	writeJSON(w, http.StatusCreated, message)
}
