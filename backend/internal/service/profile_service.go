package service

import (
	"context"

	"github.com/kimura/dating/backend/internal/domain"
)

type profileRepository interface {
	ListDiscoveryProfiles(ctx context.Context, filter domain.DiscoveryFilter) ([]domain.Profile, error)
}

type ProfileService struct {
	repo profileRepository
}

func NewProfileService(repo profileRepository) *ProfileService {
	return &ProfileService{repo: repo}
}

func (s *ProfileService) ListDiscoveryProfiles(ctx context.Context, filter domain.DiscoveryFilter) ([]domain.Profile, error) {
	return s.repo.ListDiscoveryProfiles(ctx, filter)
}
