package service

import (
	"context"
	"crypto/rand"
	"database/sql"
	"fmt"
	"math/big"
	"strings"

	"github.com/kimura/dating/backend/internal/domain"
)

type flowerRepository interface {
	ListFlowers(ctx context.Context) ([]domain.Flower, error)
	GetFlowerByID(ctx context.Context, id string) (domain.Flower, error)
	CreateFlower(ctx context.Context, id string, input domain.CreateFlowerInput) (domain.Flower, error)
	UpdateFlower(ctx context.Context, id string, input domain.UpdateFlowerInput) (domain.Flower, error)
}

type FlowerService struct {
	repo flowerRepository
}

func NewFlowerService(repo flowerRepository) *FlowerService {
	return &FlowerService{repo: repo}
}

func (s *FlowerService) ListFlowers(ctx context.Context) ([]domain.Flower, error) {
	return s.repo.ListFlowers(ctx)
}

func (s *FlowerService) CreateFlower(ctx context.Context, input domain.CreateFlowerInput) (domain.Flower, error) {
	normalized, err := normalizeCreateFlowerInput(input)
	if err != nil {
		return domain.Flower{}, err
	}

	for range 10 {
		item, createErr := s.repo.CreateFlower(ctx, generateFlowerID(), normalized)
		if createErr == nil {
			return item, nil
		}
		if !isDuplicateKeyError(createErr) {
			return domain.Flower{}, createErr
		}
	}

	return domain.Flower{}, fmt.Errorf("generate unique flower id: exhausted retries")
}

func (s *FlowerService) UpdateFlower(ctx context.Context, id string, input domain.UpdateFlowerInput) (domain.Flower, error) {
	if strings.TrimSpace(id) == "" {
		return domain.Flower{}, sql.ErrNoRows
	}

	normalized, err := normalizeUpdateFlowerInput(input)
	if err != nil {
		return domain.Flower{}, err
	}

	return s.repo.UpdateFlower(ctx, id, normalized)
}

func normalizeCreateFlowerInput(input domain.CreateFlowerInput) (domain.CreateFlowerInput, error) {
	normalized := domain.CreateFlowerInput{
		Name:        strings.TrimSpace(input.Name),
		ImageURL:    strings.TrimSpace(input.ImageURL),
		Description: strings.TrimSpace(input.Description),
		PricePoints: input.PricePoints,
		Published:   input.Published,
	}

	if err := validateFlowerFields(normalized.Name, normalized.ImageURL, normalized.Description, normalized.PricePoints); err != nil {
		return domain.CreateFlowerInput{}, err
	}

	return normalized, nil
}

func normalizeUpdateFlowerInput(input domain.UpdateFlowerInput) (domain.UpdateFlowerInput, error) {
	normalized := domain.UpdateFlowerInput{
		Name:        strings.TrimSpace(input.Name),
		ImageURL:    strings.TrimSpace(input.ImageURL),
		Description: strings.TrimSpace(input.Description),
		PricePoints: input.PricePoints,
		Published:   input.Published,
	}

	if err := validateFlowerFields(normalized.Name, normalized.ImageURL, normalized.Description, normalized.PricePoints); err != nil {
		return domain.UpdateFlowerInput{}, err
	}

	return normalized, nil
}

func validateFlowerFields(name, imageURL, description string, pricePoints int) error {
	if name == "" {
		return fmt.Errorf("flower name is required")
	}
	if len([]rune(name)) > 50 {
		return fmt.Errorf("flower name must be 50 characters or fewer")
	}
	if imageURL == "" {
		return fmt.Errorf("flower image is required")
	}
	if description == "" {
		return fmt.Errorf("flower description is required")
	}
	if len([]rune(description)) > 100 {
		return fmt.Errorf("flower description must be 100 characters or fewer")
	}
	if pricePoints <= 0 {
		return fmt.Errorf("price points must be greater than 0")
	}
	return nil
}

func generateFlowerID() string {
	const charset = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	const length = 8

	buf := make([]byte, length)
	max := big.NewInt(int64(len(charset)))
	for i := range buf {
		index, err := rand.Int(rand.Reader, max)
		if err != nil {
			buf[i] = charset[i%len(charset)]
			continue
		}
		buf[i] = charset[index.Int64()]
	}

	return string(buf)
}
