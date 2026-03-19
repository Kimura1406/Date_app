package httpapi

import (
	"net/http"
	"strconv"
	"strings"

	"github.com/kimura/dating/backend/internal/domain"
	"github.com/kimura/dating/backend/internal/service"
)

type DiscoveryHandler struct {
	profileService *service.ProfileService
}

func NewDiscoveryHandler(profileService *service.ProfileService) *DiscoveryHandler {
	return &DiscoveryHandler{profileService: profileService}
}

func (h *DiscoveryHandler) ListProfiles(w http.ResponseWriter, r *http.Request) {
	filter := domain.DiscoveryFilter{
		Country:       strings.TrimSpace(r.URL.Query().Get("country")),
		Job:           strings.TrimSpace(r.URL.Query().Get("job")),
		Gender:        strings.TrimSpace(r.URL.Query().Get("gender")),
		Location:      strings.TrimSpace(r.URL.Query().Get("location")),
		ExcludeUserID: strings.TrimSpace(r.URL.Query().Get("excludeUserId")),
	}
	if minAge, err := strconv.Atoi(strings.TrimSpace(r.URL.Query().Get("minAge"))); err == nil {
		filter.MinAge = minAge
	}
	if maxAge, err := strconv.Atoi(strings.TrimSpace(r.URL.Query().Get("maxAge"))); err == nil {
		filter.MaxAge = maxAge
	}

	items, err := h.profileService.ListDiscoveryProfiles(r.Context(), filter)
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
