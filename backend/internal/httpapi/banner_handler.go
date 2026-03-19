package httpapi

import (
	"encoding/json"
	"net/http"

	"github.com/kimura/dating/backend/internal/domain"
	"github.com/kimura/dating/backend/internal/service"
)

type BannerHandler struct {
	bannerService *service.BannerService
}

func NewBannerHandler(bannerService *service.BannerService) *BannerHandler {
	return &BannerHandler{bannerService: bannerService}
}

func (h *BannerHandler) ListBanners(w http.ResponseWriter, r *http.Request) {
	items, err := h.bannerService.ListBanners(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to load banners")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *BannerHandler) CreateBanner(w http.ResponseWriter, r *http.Request) {
	var input domain.CreateBannerInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	item, err := h.bannerService.CreateBanner(r.Context(), input)
	if err != nil {
		writeDomainError(w, err, "failed to create banner")
		return
	}

	writeJSON(w, http.StatusCreated, item)
}

func (h *BannerHandler) UpdateBanner(w http.ResponseWriter, r *http.Request) {
	var input domain.UpdateBannerInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	item, err := h.bannerService.UpdateBanner(r.Context(), r.PathValue("id"), input)
	if err != nil {
		writeDomainError(w, err, "failed to update banner")
		return
	}

	writeJSON(w, http.StatusOK, item)
}
