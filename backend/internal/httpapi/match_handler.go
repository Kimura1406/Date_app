package httpapi

import (
	"net/http"

	"github.com/kimura/dating/backend/internal/service"
)

type MatchHandler struct {
	matchService *service.MatchService
}

func NewMatchHandler(matchService *service.MatchService) *MatchHandler {
	return &MatchHandler{matchService: matchService}
}

func (h *MatchHandler) ListMatches(w http.ResponseWriter, r *http.Request) {
	items, err := h.matchService.ListMatches(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]any{
			"error": "failed to load matches",
		})
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"items": items,
	})
}
