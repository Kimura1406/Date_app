package httpapi

import (
	"net/http"

	"github.com/kimura/dating/backend/internal/service"
)

type DiscoveryHandler struct {
	profileService *service.ProfileService
}

func NewDiscoveryHandler(profileService *service.ProfileService) *DiscoveryHandler {
	return &DiscoveryHandler{profileService: profileService}
}

func (h *DiscoveryHandler) ListProfiles(w http.ResponseWriter, r *http.Request) {
	items, err := h.profileService.ListDiscoveryProfiles(r.Context())
	if err != nil {
		writeJSON(w, http.StatusInternalServerError, map[string]any{
			"error": "failed to load discovery profiles",
		})
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{
		"items": items,
	})
}
