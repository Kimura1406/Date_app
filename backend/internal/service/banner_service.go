package service

import (
	"context"
	"crypto/rand"
	"database/sql"
	"fmt"
	"math/big"
	"net/url"
	"strings"

	"github.com/kimura/dating/backend/internal/domain"
)

type bannerRepository interface {
	ListBanners(ctx context.Context) ([]domain.Banner, error)
	ListPublicBanners(ctx context.Context) ([]domain.Banner, error)
	GetBannerByID(ctx context.Context, id string) (domain.Banner, error)
	CreateBanner(ctx context.Context, id string, input domain.CreateBannerInput) (domain.Banner, error)
	UpdateBanner(ctx context.Context, id string, input domain.UpdateBannerInput) (domain.Banner, error)
}

type BannerService struct {
	repo bannerRepository
}

func NewBannerService(repo bannerRepository) *BannerService {
	return &BannerService{repo: repo}
}

func (s *BannerService) ListBanners(ctx context.Context) ([]domain.Banner, error) {
	return s.repo.ListBanners(ctx)
}

func (s *BannerService) ListPublicBanners(ctx context.Context) ([]domain.Banner, error) {
	return s.repo.ListPublicBanners(ctx)
}

func (s *BannerService) CreateBanner(ctx context.Context, input domain.CreateBannerInput) (domain.Banner, error) {
	normalized, err := normalizeCreateBannerInput(input)
	if err != nil {
		return domain.Banner{}, err
	}

	for range 10 {
		item, createErr := s.repo.CreateBanner(ctx, generateBannerID(), normalized)
		if createErr == nil {
			return item, nil
		}
		if !isDuplicateKeyError(createErr) {
			return domain.Banner{}, createErr
		}
	}

	return domain.Banner{}, fmt.Errorf("generate unique banner id: exhausted retries")
}

func (s *BannerService) UpdateBanner(ctx context.Context, id string, input domain.UpdateBannerInput) (domain.Banner, error) {
	if strings.TrimSpace(id) == "" {
		return domain.Banner{}, sql.ErrNoRows
	}

	normalized, err := normalizeUpdateBannerInput(input)
	if err != nil {
		return domain.Banner{}, err
	}

	return s.repo.UpdateBanner(ctx, id, normalized)
}

func normalizeCreateBannerInput(input domain.CreateBannerInput) (domain.CreateBannerInput, error) {
	normalized := domain.CreateBannerInput{
		ImageURL:     strings.TrimSpace(input.ImageURL),
		EventName:    strings.TrimSpace(input.EventName),
		DisplayOrder: input.DisplayOrder,
		RedirectLink: strings.TrimSpace(input.RedirectLink),
		Published:    input.Published,
	}

	if err := validateBannerFields(normalized.ImageURL, normalized.EventName, normalized.DisplayOrder, normalized.RedirectLink); err != nil {
		return domain.CreateBannerInput{}, err
	}

	return normalized, nil
}

func normalizeUpdateBannerInput(input domain.UpdateBannerInput) (domain.UpdateBannerInput, error) {
	normalized := domain.UpdateBannerInput{
		ImageURL:     strings.TrimSpace(input.ImageURL),
		EventName:    strings.TrimSpace(input.EventName),
		DisplayOrder: input.DisplayOrder,
		RedirectLink: strings.TrimSpace(input.RedirectLink),
		Published:    input.Published,
	}

	if err := validateBannerFields(normalized.ImageURL, normalized.EventName, normalized.DisplayOrder, normalized.RedirectLink); err != nil {
		return domain.UpdateBannerInput{}, err
	}

	return normalized, nil
}

func validateBannerFields(imageURL, eventName string, displayOrder int, redirectLink string) error {
	if imageURL == "" {
		return fmt.Errorf("banner image is required")
	}
	if eventName == "" {
		return fmt.Errorf("event name is required")
	}
	if len([]rune(eventName)) > 100 {
		return fmt.Errorf("event name must be 100 characters or fewer")
	}
	if displayOrder < 0 {
		return fmt.Errorf("display order must be 0 or greater")
	}
	if redirectLink == "" {
		return fmt.Errorf("redirect link is required")
	}
	if _, err := url.ParseRequestURI(redirectLink); err != nil {
		return fmt.Errorf("redirect link must be a valid URL")
	}
	return nil
}

func generateBannerID() string {
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
