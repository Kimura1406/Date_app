package service

import (
	"context"
	"crypto/rand"
	"database/sql"
	"errors"
	"fmt"
	"math/big"
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
	UpdateLastLogin(ctx context.Context, id string, loggedInAt time.Time) error
	AddPoints(ctx context.Context, id string, points int) (domain.User, error)
	GetLikeSummary(ctx context.Context, targetUserID, viewerUserID string) (domain.UserLikeSummary, error)
	ToggleLike(ctx context.Context, targetUserID, viewerUserID string) (domain.UserLikeSummary, error)
	ListUsersWhoLiked(ctx context.Context, targetUserID string) ([]domain.UserLiker, error)
	BlockUser(ctx context.Context, blockedUserID, blockerUserID string) error
	ListBlockedUsers(ctx context.Context, blockerUserID string) ([]domain.BlockedUser, error)
	ReportUser(ctx context.Context, reportedUserID, reporterUserID, reason string) error
	ListReportedUsers(ctx context.Context) ([]domain.ReportedUserSummary, error)
	DeleteUser(ctx context.Context, id string) error
}

type sessionRepository interface {
	CreateSession(ctx context.Context, id, userID, tokenHash string, expiresAt time.Time) error
	GetSessionByTokenHash(ctx context.Context, tokenHash string) (domain.Session, error)
	RevokeSessionByTokenHash(ctx context.Context, tokenHash string) error
}

type userChatRepository interface {
	EnsureAdminRoomForUser(ctx context.Context, userID string) error
}

type UserService struct {
	repo            userRepository
	sessionRepo     sessionRepository
	chatRepo        userChatRepository
	tokenManager    *backendauth.TokenManager
	refreshTokenTTL time.Duration
}

func NewUserService(
	repo userRepository,
	sessionRepo sessionRepository,
	chatRepo userChatRepository,
	tokenManager *backendauth.TokenManager,
	refreshTokenTTL time.Duration,
) *UserService {
	return &UserService{
		repo:            repo,
		sessionRepo:     sessionRepo,
		chatRepo:        chatRepo,
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

	normalized, err := normalizeCreateInput(input)
	if err != nil {
		return domain.User{}, err
	}

	for range 10 {
		user, createErr := s.repo.CreateUser(ctx, generateUserID(), normalized, string(passwordHash))
		if createErr == nil {
			if s.chatRepo != nil {
				if err := s.chatRepo.EnsureAdminRoomForUser(ctx, user.ID); err != nil {
					return domain.User{}, err
				}
			}
			return user, nil
		}
		if !isDuplicateKeyError(createErr) {
			return domain.User{}, createErr
		}
	}

	return domain.User{}, fmt.Errorf("generate unique user id: exhausted retries")
}

func (s *UserService) UpdateUser(ctx context.Context, id string, input domain.UpdateUserInput) (domain.User, error) {
	if err := validateUpdateUser(input); err != nil {
		return domain.User{}, err
	}

	normalized, err := normalizeUpdateInput(input)
	if err != nil {
		return domain.User{}, err
	}
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

func (s *UserService) AddPoints(ctx context.Context, id string, input domain.UserPointGrantInput) (domain.User, error) {
	if strings.TrimSpace(id) == "" {
		return domain.User{}, sql.ErrNoRows
	}
	if input.Points <= 0 {
		return domain.User{}, fmt.Errorf("points must be greater than 0")
	}

	user, err := s.repo.GetUserByID(ctx, id)
	if err != nil {
		return domain.User{}, err
	}
	if user.Role != "user" {
		return domain.User{}, fmt.Errorf("points can only be granted to users")
	}

	return s.repo.AddPoints(ctx, id, input.Points)
}

func (s *UserService) GetLikeSummary(ctx context.Context, targetUserID, viewerUserID string) (domain.UserLikeSummary, error) {
	if strings.TrimSpace(targetUserID) == "" {
		return domain.UserLikeSummary{}, fmt.Errorf("target user id is required")
	}
	if strings.TrimSpace(viewerUserID) == "" {
		return domain.UserLikeSummary{}, fmt.Errorf("viewer user id is required")
	}

	if _, err := s.repo.GetUserByID(ctx, targetUserID); err != nil {
		return domain.UserLikeSummary{}, err
	}

	return s.repo.GetLikeSummary(ctx, targetUserID, viewerUserID)
}

func (s *UserService) ToggleLike(ctx context.Context, targetUserID, viewerUserID string) (domain.UserLikeSummary, error) {
	targetUserID = strings.TrimSpace(targetUserID)
	viewerUserID = strings.TrimSpace(viewerUserID)
	if targetUserID == "" {
		return domain.UserLikeSummary{}, fmt.Errorf("target user id is required")
	}
	if viewerUserID == "" {
		return domain.UserLikeSummary{}, fmt.Errorf("viewer user id is required")
	}
	if targetUserID == viewerUserID {
		return domain.UserLikeSummary{}, fmt.Errorf("cannot like yourself")
	}

	targetUser, err := s.repo.GetUserByID(ctx, targetUserID)
	if err != nil {
		return domain.UserLikeSummary{}, err
	}
	if targetUser.Role != "user" {
		return domain.UserLikeSummary{}, fmt.Errorf("likes are only available for users")
	}

	if _, err := s.repo.GetUserByID(ctx, viewerUserID); err != nil {
		return domain.UserLikeSummary{}, err
	}

	return s.repo.ToggleLike(ctx, targetUserID, viewerUserID)
}

func (s *UserService) ListUsersWhoLiked(ctx context.Context, targetUserID string) ([]domain.UserLiker, error) {
	targetUserID = strings.TrimSpace(targetUserID)
	if targetUserID == "" {
		return nil, fmt.Errorf("target user id is required")
	}

	if _, err := s.repo.GetUserByID(ctx, targetUserID); err != nil {
		return nil, err
	}

	return s.repo.ListUsersWhoLiked(ctx, targetUserID)
}

func (s *UserService) BlockUser(ctx context.Context, blockedUserID, blockerUserID string) error {
	blockedUserID = strings.TrimSpace(blockedUserID)
	blockerUserID = strings.TrimSpace(blockerUserID)
	if blockedUserID == "" {
		return fmt.Errorf("blocked user id is required")
	}
	if blockerUserID == "" {
		return fmt.Errorf("blocker user id is required")
	}
	if blockedUserID == blockerUserID {
		return fmt.Errorf("cannot block yourself")
	}

	blockedUser, err := s.repo.GetUserByID(ctx, blockedUserID)
	if err != nil {
		return err
	}
	if blockedUser.Role != "user" {
		return fmt.Errorf("only users can be blocked")
	}

	if _, err := s.repo.GetUserByID(ctx, blockerUserID); err != nil {
		return err
	}

	return s.repo.BlockUser(ctx, blockedUserID, blockerUserID)
}

func (s *UserService) ListBlockedUsers(ctx context.Context, blockerUserID string) ([]domain.BlockedUser, error) {
	blockerUserID = strings.TrimSpace(blockerUserID)
	if blockerUserID == "" {
		return nil, fmt.Errorf("blocker user id is required")
	}

	if _, err := s.repo.GetUserByID(ctx, blockerUserID); err != nil {
		return nil, err
	}

	return s.repo.ListBlockedUsers(ctx, blockerUserID)
}

func (s *UserService) ReportUser(ctx context.Context, reportedUserID, reporterUserID string, input domain.UserReportInput) error {
	reportedUserID = strings.TrimSpace(reportedUserID)
	reporterUserID = strings.TrimSpace(reporterUserID)
	reason := strings.TrimSpace(input.Reason)

	if reportedUserID == "" {
		return fmt.Errorf("reported user id is required")
	}
	if reporterUserID == "" {
		return fmt.Errorf("reporter user id is required")
	}
	if reportedUserID == reporterUserID {
		return fmt.Errorf("cannot report yourself")
	}
	if reason == "" {
		return fmt.Errorf("report reason is required")
	}
	if len([]rune(reason)) > 100 {
		return fmt.Errorf("report reason must be 100 characters or fewer")
	}

	reportedUser, err := s.repo.GetUserByID(ctx, reportedUserID)
	if err != nil {
		return err
	}
	if reportedUser.Role != "user" {
		return fmt.Errorf("only users can be reported")
	}

	if _, err := s.repo.GetUserByID(ctx, reporterUserID); err != nil {
		return err
	}

	return s.repo.ReportUser(ctx, reportedUserID, reporterUserID, reason)
}

func (s *UserService) ListReportedUsers(ctx context.Context) ([]domain.ReportedUserSummary, error) {
	return s.repo.ListReportedUsers(ctx)
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

	if err := s.repo.UpdateLastLogin(ctx, user.ID, time.Now()); err != nil {
		return domain.AuthResponse{}, err
	}

	user, err = s.repo.GetUserByID(ctx, credentials.ID)
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
	if _, err := parseBirthDate(input.BirthDate); err != nil {
		return err
	}
	if strings.TrimSpace(input.Country) == "" {
		return fmt.Errorf("country is required")
	}
	if strings.TrimSpace(input.Prefecture) == "" {
		return fmt.Errorf("prefecture is required")
	}
	if strings.TrimSpace(input.DatingReason) == "" {
		return fmt.Errorf("dating reason is required")
	}
	if len([]rune(strings.TrimSpace(input.DatingReason))) > 100 {
		return fmt.Errorf("dating reason must be 100 characters or fewer")
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
	if _, err := parseBirthDate(input.BirthDate); err != nil {
		return err
	}
	if strings.TrimSpace(input.Country) == "" {
		return fmt.Errorf("country is required")
	}
	if strings.TrimSpace(input.Prefecture) == "" {
		return fmt.Errorf("prefecture is required")
	}
	if strings.TrimSpace(input.DatingReason) == "" {
		return fmt.Errorf("dating reason is required")
	}
	if len([]rune(strings.TrimSpace(input.DatingReason))) > 100 {
		return fmt.Errorf("dating reason must be 100 characters or fewer")
	}
	return nil
}

func normalizeCreateInput(input domain.CreateUserInput) (domain.CreateUserInput, error) {
	birthDate, err := parseBirthDate(input.BirthDate)
	if err != nil {
		return domain.CreateUserInput{}, err
	}

	input.Email = strings.TrimSpace(strings.ToLower(input.Email))
	input.Password = strings.TrimSpace(input.Password)
	input.Name = strings.TrimSpace(input.Name)
	input.Job = strings.TrimSpace(input.Job)
	input.Bio = strings.TrimSpace(input.Bio)
	input.Distance = strings.TrimSpace(input.Distance)
	input.Interests = normalizeInterests(input.Interests)
	input.BirthDate = birthDate.Format("2006-01-02")
	input.Country = strings.TrimSpace(input.Country)
	input.Prefecture = strings.TrimSpace(input.Prefecture)
	input.DatingReason = strings.TrimSpace(input.DatingReason)
	input.Age = calculateAge(birthDate, time.Now())
	return input, nil
}

func normalizeUpdateInput(input domain.UpdateUserInput) (domain.UpdateUserInput, error) {
	birthDate, err := parseBirthDate(input.BirthDate)
	if err != nil {
		return domain.UpdateUserInput{}, err
	}

	input.Email = strings.TrimSpace(strings.ToLower(input.Email))
	input.Password = strings.TrimSpace(input.Password)
	input.Name = strings.TrimSpace(input.Name)
	input.Job = strings.TrimSpace(input.Job)
	input.Bio = strings.TrimSpace(input.Bio)
	input.Distance = strings.TrimSpace(input.Distance)
	input.Interests = normalizeInterests(input.Interests)
	input.BirthDate = birthDate.Format("2006-01-02")
	input.Country = strings.TrimSpace(input.Country)
	input.Prefecture = strings.TrimSpace(input.Prefecture)
	input.DatingReason = strings.TrimSpace(input.DatingReason)
	input.Age = calculateAge(birthDate, time.Now())
	return input, nil
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
	const digits = "123456789"
	const letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	var builder strings.Builder
	builder.Grow(8)
	for i := 0; i < 3; i++ {
		builder.WriteByte(randomCharsetByte(digits))
	}
	for i := 0; i < 5; i++ {
		builder.WriteByte(randomCharsetByte(letters))
	}
	return builder.String()
}

func generateSessionID() string {
	return "ses_" + generateHexID(12)
}

func generateHexID(size int) string {
	bytes := make([]byte, size/2)
	if _, err := rand.Read(bytes); err != nil {
		return fmt.Sprintf("fallback%d", len(bytes))
	}
	const hexdigits = "0123456789abcdef"
	var builder strings.Builder
	builder.Grow(len(bytes) * 2)
	for _, value := range bytes {
		builder.WriteByte(hexdigits[value>>4])
		builder.WriteByte(hexdigits[value&0x0f])
	}
	return builder.String()
}

func randomCharsetByte(charset string) byte {
	if len(charset) == 0 {
		return 'X'
	}

	n, err := rand.Int(rand.Reader, big.NewInt(int64(len(charset))))
	if err != nil {
		return charset[0]
	}
	return charset[n.Int64()]
}

func parseBirthDate(value string) (time.Time, error) {
	birthDate, err := time.Parse("2006-01-02", strings.TrimSpace(value))
	if err != nil {
		return time.Time{}, fmt.Errorf("birth date must be in YYYY-MM-DD format")
	}
	if birthDate.After(time.Now()) {
		return time.Time{}, fmt.Errorf("birth date cannot be in the future")
	}
	return birthDate, nil
}

func calculateAge(birthDate time.Time, now time.Time) int {
	age := now.Year() - birthDate.Year()
	if now.Month() < birthDate.Month() || (now.Month() == birthDate.Month() && now.Day() < birthDate.Day()) {
		age--
	}
	if age < 0 {
		return 0
	}
	return age
}

func isDuplicateKeyError(err error) bool {
	if err == nil {
		return false
	}
	return strings.Contains(strings.ToLower(err.Error()), "duplicate key")
}
