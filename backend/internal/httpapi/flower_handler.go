package httpapi

import (
	"encoding/json"
	"net/http"

	"github.com/kimura/dating/backend/internal/domain"
	"github.com/kimura/dating/backend/internal/service"
)

type FlowerHandler struct {
	flowerService *service.FlowerService
}

func NewFlowerHandler(flowerService *service.FlowerService) *FlowerHandler {
	return &FlowerHandler{flowerService: flowerService}
}

func (h *FlowerHandler) ListFlowers(w http.ResponseWriter, r *http.Request) {
	items, err := h.flowerService.ListFlowers(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to load flowers")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *FlowerHandler) ListPublicFlowers(w http.ResponseWriter, r *http.Request) {
	items, err := h.flowerService.ListPublishedFlowers(r.Context())
	if err != nil {
		writeError(w, http.StatusInternalServerError, "failed to load flowers")
		return
	}

	writeJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *FlowerHandler) CreateFlower(w http.ResponseWriter, r *http.Request) {
	var input domain.CreateFlowerInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	item, err := h.flowerService.CreateFlower(r.Context(), input)
	if err != nil {
		writeDomainError(w, err, "failed to create flower")
		return
	}

	writeJSON(w, http.StatusCreated, item)
}

func (h *FlowerHandler) UpdateFlower(w http.ResponseWriter, r *http.Request) {
	var input domain.UpdateFlowerInput
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		writeError(w, http.StatusBadRequest, "invalid request body")
		return
	}

	item, err := h.flowerService.UpdateFlower(r.Context(), r.PathValue("id"), input)
	if err != nil {
		writeDomainError(w, err, "failed to update flower")
		return
	}

	writeJSON(w, http.StatusOK, item)
}
