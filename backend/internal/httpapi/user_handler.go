package httpapi

import (
	"database/sql"
	"encoding/json"
	"errors"
	"log"
	"net/http"

	backendauth "github.com/kimura/dating/backend/internal/auth"
	"github.com/kimura/dating/backend/internal/domain"
	"github.com/kimura/dating/backend/internal/service"
)

type UserHandler struct {
	userService *service.UserService
}

func NewUserHandler(userService *service.UserService, tokenManager *backendauth.TokenManager) *UserHandler {
	_ = tokenManager
	return &UserHandler{userService: userService}
}

func (h *UserHandler) ListUsers(w http.ResponseWriter, r *http.Request) {
	users, err := h.userService.ListUsers(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to load users")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": users})
}

func (h *UserHandler) GetUser(w http.ResponseWriter, r *http.Request) {
	if !canAccessUser(r, r.PathValue("id")) {
		writeError(w, http.StatusForbidden, "forbidden")
		return
	}

	user, err := h.userService.GetUser(r.Context(), r.PathValue("id"))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeError(w, http.StatusInternalServerError, "failed to load user")
		return
	}

	writeJSON(w, http.StatusOK, user)
}

func (h *UserHandler) CreateUser(w http.ResponseWriter, r *http.Request) {
	var input domain.CreateUserInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	user, err := h.userService.CreateUser(r.Context(), input)
	if err != nil {
		writeDomainError(w, err, "failed to create user")
		return
	}

	writeJSON(w, http.StatusCreated, user)
}

func (h *UserHandler) Me(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	user, err := h.userService.GetUser(r.Context(), claims.Subject)
	if err != nil {
		writeDomainError(w, err, "failed to load current user")
		return
	}

	writeJSON(w, http.StatusOK, user)
}

func (h *UserHandler) UpdateUser(w http.ResponseWriter, r *http.Request) {
	if !canAccessUser(r, r.PathValue("id")) {
		writeError(w, http.StatusForbidden, "forbidden")
		return
	}

	var input domain.UpdateUserInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	user, err := h.userService.UpdateUser(r.Context(), r.PathValue("id"), input)
	if err != nil {
		writeDomainError(w, err, "failed to update user")
		return
	}

	writeJSON(w, http.StatusOK, user)
}

func (h *UserHandler) DeleteUser(w http.ResponseWriter, r *http.Request) {
	if !canAccessUser(r, r.PathValue("id")) {
		writeError(w, http.StatusForbidden, "forbidden")
		return
	}

	err := h.userService.DeleteUser(r.Context(), r.PathValue("id"))
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeError(w, http.StatusInternalServerError, "failed to delete user")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"deleted": true})
}

func (h *UserHandler) GetLikeSummary(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	summary, err := h.userService.GetLikeSummary(r.Context(), r.PathValue("id"), claims.Subject)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeDomainError(w, err, "failed to load like summary")
		return
	}

	writeJSON(w, http.StatusOK, summary)
}

func (h *UserHandler) ToggleLike(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	summary, err := h.userService.ToggleLike(r.Context(), r.PathValue("id"), claims.Subject)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeDomainError(w, err, "failed to toggle like")
		return
	}

	writeJSON(w, http.StatusOK, summary)
}

func (h *UserHandler) ListUsersWhoLikedMe(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	items, err := h.userService.ListUsersWhoLiked(r.Context(), claims.Subject)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeDomainError(w, err, "failed to load users who liked")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *UserHandler) BlockUser(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	if err := h.userService.BlockUser(r.Context(), r.PathValue("id"), claims.Subject); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeDomainError(w, err, "failed to block user")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"blocked": true})
}

func (h *UserHandler) ListBlockedUsers(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	items, err := h.userService.ListBlockedUsers(r.Context(), claims.Subject)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeDomainError(w, err, "failed to load blocked users")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *UserHandler) ReportUser(w http.ResponseWriter, r *http.Request) {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		writeError(w, http.StatusUnauthorized, "missing auth context")
		return
	}

	var input domain.UserReportInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.userService.ReportUser(r.Context(), r.PathValue("id"), claims.Subject, input); err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeDomainError(w, err, "failed to report user")
		return
	}

	writeJSON(w, http.StatusCreated, map[string]any{"reported": true})
}

func (h *UserHandler) AddPoints(w http.ResponseWriter, r *http.Request) {
	var input domain.UserPointGrantInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	user, err := h.userService.AddPoints(r.Context(), r.PathValue("id"), input)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			writeError(w, http.StatusNotFound, "user not found")
			return
		}
		writeDomainError(w, err, "failed to grant points")
		return
	}

	writeJSON(w, http.StatusOK, user)
}

func (h *UserHandler) Login(w http.ResponseWriter, r *http.Request) {
	h.login(w, r, false)
}

func (h *UserHandler) AdminLogin(w http.ResponseWriter, r *http.Request) {
	h.login(w, r, true)
}

func (h *UserHandler) login(w http.ResponseWriter, r *http.Request, adminOnly bool) {
	var input domain.LoginInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	var (
		authResponse domain.AuthResponse
		err          error
	)
	if adminOnly {
		authResponse, err = h.userService.LoginAdmin(r.Context(), input)
	} else {
		authResponse, err = h.userService.Login(r.Context(), input)
	}
	if err != nil {
		if errors.Is(err, service.ErrInvalidCredentials) {
			writeError(w, http.StatusUnauthorized, "invalid email or password")
			return
		}
		log.Printf("auth login failed adminOnly=%t email=%q: %v", adminOnly, input.Email, err)
		writeError(w, http.StatusInternalServerError, "failed to login")
		return
	}

	writeJSON(w, http.StatusOK, authResponse)
}

func (h *UserHandler) Refresh(w http.ResponseWriter, r *http.Request) {
	var input domain.RefreshInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	authResponse, err := h.userService.RefreshSession(r.Context(), input.RefreshToken)
	if err != nil {
		if errors.Is(err, service.ErrInvalidRefreshToken) {
			writeError(w, http.StatusUnauthorized, "invalid refresh token")
			return
		}
		log.Printf("auth refresh failed: %v", err)
		writeError(w, http.StatusInternalServerError, "failed to refresh session")
		return
	}

	writeJSON(w, http.StatusOK, authResponse)
}

func (h *UserHandler) Logout(w http.ResponseWriter, r *http.Request) {
	var input domain.LogoutInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	if err := h.userService.Logout(r.Context(), input.RefreshToken); err != nil {
		if errors.Is(err, service.ErrInvalidRefreshToken) {
			writeError(w, http.StatusUnauthorized, "invalid refresh token")
			return
		}
		log.Printf("auth logout failed: %v", err)
		writeError(w, http.StatusInternalServerError, "failed to logout")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"loggedOut": true})
}

func canAccessUser(r *http.Request, userID string) bool {
	claims, ok := authClaimsFromContext(r.Context())
	if !ok {
		return false
	}

	return claims.Role == "admin" || claims.Subject == userID
}
