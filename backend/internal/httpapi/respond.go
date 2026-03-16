package httpapi

import (
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"strings"

	"github.com/kimura/dating/backend/internal/service"
)

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(payload)
}

func writeError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{
		"error": message,
	})
}

func writeDomainError(w http.ResponseWriter, err error, fallback string) {
	switch {
	case errors.Is(err, sql.ErrNoRows):
		writeError(w, http.StatusNotFound, "user not found")
	case errors.Is(err, service.ErrInvalidCredentials):
		writeError(w, http.StatusUnauthorized, "invalid email or password")
	case isValidationError(err):
		writeError(w, http.StatusBadRequest, err.Error())
	default:
		writeError(w, http.StatusInternalServerError, fallback)
	}
}

func isValidationError(err error) bool {
	message := err.Error()
	return strings.Contains(message, "required") ||
		strings.Contains(message, "greater than 0") ||
		strings.Contains(message, "duplicate key") ||
		strings.Contains(strings.ToLower(message), "unique")
}
