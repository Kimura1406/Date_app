package service

import (
	"context"

	"github.com/kimura/dating/backend/internal/domain"
)

type matchRepository interface {
	ListMatches(ctx context.Context) ([]domain.Match, error)
}

type MatchService struct {
	repo matchRepository
}

func NewMatchService(repo matchRepository) *MatchService {
	return &MatchService{repo: repo}
}

func (s *MatchService) ListMatches(ctx context.Context) ([]domain.Match, error) {
	return s.repo.ListMatches(ctx)
}
