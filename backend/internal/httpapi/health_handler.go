package httpapi

import (
	"net/http"

	"github.com/kimura/dating/backend/internal/config"
)

type HealthHandler struct {
	config config.Config
}

func NewHealthHandler(cfg config.Config) *HealthHandler {
	return &HealthHandler{config: cfg}
}

func (h *HealthHandler) Handle(w http.ResponseWriter, _ *http.Request) {
	writeJSON(w, http.StatusOK, map[string]string{
		"status": "ok",
		"env":    h.config.AppEnv,
	})
}
