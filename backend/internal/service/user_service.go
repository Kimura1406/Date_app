package service

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"time"

	backendauth "github.com/kimura/dating/backend/internal/auth"
	"github.com/kimura/dating/backend/internal/domain"
	"golang.org/x/crypto/bcrypt"
)

var ErrInvalidCredentials = errors.New("invalid credentials")
var ErrInvalidRefreshToken = errors.New("invalid refresh token")

type userRepository interface {
	ListUsers(ctx context.Context) ([]domain.User, error)
	GetUserByID(ctx context.Context, id string) (domain.User, error)
	GetCredentialsByEmail(ctx context.Context, email string) (domain.UserCredentials, error)
	CreateUser(ctx context.Context, id string, input domain.CreateUserInput, passwordHash string) (domain.User, error)
	UpdateUser(ctx context.Context, id string, input domain.UpdateUserInput, passwordHash *string) (domain.User, error)
	DeleteUser(ctx context.Context, id string) error
}

type sessionRepository interface {
	CreateSession(ctx context.Context, id, userID, tokenHash string, expiresAt time.Time) error
	GetSessionByTokenHash(ctx context.Context, tokenHash string) (domain.Session, error)
	RevokeSessionByTokenHash(ctx context.Context, tokenHash string) error
}

type UserService struct {
	repo            userRepository
	sessionRepo     sessionRepository
	tokenManager    *backendauth.TokenManager
	refreshTokenTTL time.Duration
}

func NewUserService(
	repo userRepository,
	sessionRepo sessionRepository,
	tokenManager *backendauth.TokenManager,
	refreshTokenTTL time.Duration,
) *UserService {
	return &UserService{
		repo:            repo,
		sessionRepo:     sessionRepo,
		tokenManager:    tokenManager,
		refreshTokenTTL: refreshTokenTTL,
	}
}

func (s *UserService) ListUsers(ctx context.Context) ([]domain.User, error) {
	return s.repo.ListUsers(ctx)
}

func (s *UserService) GetUser(ctx context.Context, id string) (domain.User, error) {
	return s.repo.GetUserByID(ctx, id)
}

func (s *UserService) CreateUser(ctx context.Context, input domain.CreateUserInput) (domain.User, error) {
	if err := validateCreateUser(input); err != nil {
		return domain.User{}, err
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return domain.User{}, fmt.Errorf("hash password: %w", err)
	}

	return s.repo.CreateUser(ctx, generateUserID(), normalizeCreateInput(input), string(passwordHash))
}

func (s *UserService) UpdateUser(ctx context.Context, id string, input domain.UpdateUserInput) (domain.User, error) {
	if err := validateUpdateUser(input); err != nil {
		return domain.User{}, err
	}

	normalized := normalizeUpdateInput(input)
	var passwordHash *string
	if strings.TrimSpace(normalized.Password) != "" {
		hashed, err := bcrypt.GenerateFromPassword([]byte(normalized.Password), bcrypt.DefaultCost)
		if err != nil {
			return domain.User{}, fmt.Errorf("hash password: %w", err)
		}
		hashString := string(hashed)
		passwordHash = &hashString
	}

	return s.repo.UpdateUser(ctx, id, normalized, passwordHash)
}

func (s *UserService) DeleteUser(ctx context.Context, id string) error {
	return s.repo.DeleteUser(ctx, id)
}

func (s *UserService) Login(ctx context.Context, input domain.LoginInput) (domain.AuthResponse, error) {
	return s.loginWithRole(ctx, input, "")
}

func (s *UserService) LoginAdmin(ctx context.Context, input domain.LoginInput) (domain.AuthResponse, error) {
	return s.loginWithRole(ctx, input, "admin")
}

func (s *UserService) RefreshSession(ctx context.Context, refreshToken string) (domain.AuthResponse, error) {
	tokenHash := s.tokenManager.HashRefreshToken(strings.TrimSpace(refreshToken))
	session, err := s.sessionRepo.GetSessionByTokenHash(ctx, tokenHash)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return domain.AuthResponse{}, ErrInvalidRefreshToken
		}
		return domain.AuthResponse{}, err
	}

	if session.RevokedAt != "" {
		return domain.AuthResponse{}, ErrInvalidRefreshToken
	}

	expiresAt, err := time.Parse(time.RFC3339, session.ExpiresAt)
	if err != nil || time.Now().After(expiresAt) {
		return domain.AuthResponse{}, ErrInvalidRefreshToken
	}

	user, err := s.repo.GetUserByID(ctx, session.UserID)
	if err != nil {
		return domain.AuthResponse{}, err
	}

	if err := s.sessionRepo.RevokeSessionByTokenHash(ctx, tokenHash); err != nil {
		return domain.AuthResponse{}, err
	}

	return s.createAuthResponse(ctx, user)
}

func (s *UserService) Logout(ctx context.Context, refreshToken string) error {
	tokenHash := s.tokenManager.HashRefreshToken(strings.TrimSpace(refreshToken))
	if tokenHash == s.tokenManager.HashRefreshToken("") {
		return ErrInvalidRefreshToken
	}

	err := s.sessionRepo.RevokeSessionByTokenHash(ctx, tokenHash)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return ErrInvalidRefreshToken
		}
		return err
	}
	return nil
}

func (s *UserService) loginWithRole(ctx context.Context, input domain.LoginInput, requiredRole string) (domain.AuthResponse, error) {
	email := strings.TrimSpace(strings.ToLower(input.Email))
	password := strings.TrimSpace(input.Password)
	if email == "" || password == "" {
		return domain.AuthResponse{}, ErrInvalidCredentials
	}

	credentials, err := s.repo.GetCredentialsByEmail(ctx, email)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			return domain.AuthResponse{}, ErrInvalidCredentials
		}
		return domain.AuthResponse{}, err
	}

	if err := bcrypt.CompareHashAndPassword([]byte(credentials.PasswordHash), []byte(password)); err != nil {
		return domain.AuthResponse{}, ErrInvalidCredentials
	}

	if requiredRole != "" && credentials.Role != requiredRole {
		return domain.AuthResponse{}, ErrInvalidCredentials
	}

	user, err := s.repo.GetUserByID(ctx, credentials.ID)
	if err != nil {
		return domain.AuthResponse{}, err
	}

	return s.createAuthResponse(ctx, user)
}

func (s *UserService) createAuthResponse(ctx context.Context, user domain.User) (domain.AuthResponse, error) {
	accessToken, err := s.tokenManager.GenerateToken(user)
	if err != nil {
		return domain.AuthResponse{}, fmt.Errorf("generate access token: %w", err)
	}

	refreshToken, err := s.tokenManager.GenerateRefreshToken()
	if err != nil {
		return domain.AuthResponse{}, fmt.Errorf("generate refresh token: %w", err)
	}

	expiresAt := time.Now().Add(s.refreshTokenTTL)
	if err := s.sessionRepo.CreateSession(
		ctx,
		generateSessionID(),
		user.ID,
		s.tokenManager.HashRefreshToken(refreshToken),
		expiresAt,
	); err != nil {
		return domain.AuthResponse{}, err
	}

	return domain.AuthResponse{
		User: user,
		Tokens: domain.AuthTokens{
			AccessToken:  accessToken,
			RefreshToken: refreshToken,
			TokenType:    "Bearer",
			ExpiresIn:    s.tokenManager.ExpiresInSeconds(),
		},
	}, nil
}

func validateCreateUser(input domain.CreateUserInput) error {
	if strings.TrimSpace(input.Email) == "" {
		return fmt.Errorf("email is required")
	}
	if strings.TrimSpace(input.Password) == "" {
		return fmt.Errorf("password is required")
	}
	if strings.TrimSpace(input.Name) == "" {
		return fmt.Errorf("name is required")
	}
	if input.Age <= 0 {
		return fmt.Errorf("age must be greater than 0")
	}
	return nil
}

func validateUpdateUser(input domain.UpdateUserInput) error {
	if strings.TrimSpace(input.Email) == "" {
		return fmt.Errorf("email is required")
	}
	if strings.TrimSpace(input.Name) == "" {
		return fmt.Errorf("name is required")
	}
	if input.Age <= 0 {
		return fmt.Errorf("age must be greater than 0")
	}
	return nil
}

func normalizeCreateInput(input domain.CreateUserInput) domain.CreateUserInput {
	input.Email = strings.TrimSpace(strings.ToLower(input.Email))
	input.Password = strings.TrimSpace(input.Password)
	input.Name = strings.TrimSpace(input.Name)
	input.Job = strings.TrimSpace(input.Job)
	input.Bio = strings.TrimSpace(input.Bio)
	input.Distance = strings.TrimSpace(input.Distance)
	input.Interests = normalizeInterests(input.Interests)
	return input
}

func normalizeUpdateInput(input domain.UpdateUserInput) domain.UpdateUserInput {
	input.Email = strings.TrimSpace(strings.ToLower(input.Email))
	input.Password = strings.TrimSpace(input.Password)
	input.Name = strings.TrimSpace(input.Name)
	input.Job = strings.TrimSpace(input.Job)
	input.Bio = strings.TrimSpace(input.Bio)
	input.Distance = strings.TrimSpace(input.Distance)
	input.Interests = normalizeInterests(input.Interests)
	return input
}

func normalizeInterests(interests []string) []string {
	normalized := make([]string, 0, len(interests))
	for _, interest := range interests {
		value := strings.TrimSpace(interest)
		if value != "" {
			normalized = append(normalized, value)
		}
	}
	return normalized
}

func generateUserID() string {
	return generateID("usr_")
}

func generateSessionID() string {
	return generateID("ses_")
}

func generateID(prefix string) string {
	bytes := make([]byte, 6)
	if _, err := rand.Read(bytes); err != nil {
		return fmt.Sprintf("%s%d", prefix, len(bytes))
	}
	return prefix + hex.EncodeToString(bytes)
}
