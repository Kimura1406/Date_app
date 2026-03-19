package httpapi

import (
	"net/http"

	backendauth "github.com/kimura/dating/backend/internal/auth"
	"github.com/kimura/dating/backend/internal/config"
	"github.com/kimura/dating/backend/internal/service"
)

func NewRouter(
	cfg config.Config,
	profileService *service.ProfileService,
	matchService *service.MatchService,
	chatService *service.ChatService,
	flowerService *service.FlowerService,
	bannerService *service.BannerService,
	userService *service.UserService,
	tokenManager *backendauth.TokenManager,
) http.Handler {
	mux := http.NewServeMux()

	healthHandler := NewHealthHandler(cfg)
	discoveryHandler := NewDiscoveryHandler(profileService)
	matchHandler := NewMatchHandler(matchService)
	chatHandler := NewChatHandler(chatService)
	flowerHandler := NewFlowerHandler(flowerService)
	bannerHandler := NewBannerHandler(bannerService)
	userHandler := NewUserHandler(userService, tokenManager)

	mux.HandleFunc("GET /health", healthHandler.Handle)
	mux.HandleFunc("GET /api/v1/discovery", discoveryHandler.ListProfiles)
	mux.HandleFunc("GET /api/v1/matches", matchHandler.ListMatches)
	mux.HandleFunc("GET /api/v1/flowers", flowerHandler.ListPublicFlowers)
	mux.HandleFunc("POST /api/v1/admin/auth/login", userHandler.AdminLogin)
	mux.HandleFunc("POST /api/v1/admin/auth/logout", userHandler.Logout)
	mux.HandleFunc("GET /api/v1/admin/users", withAuth(tokenManager, requireRole("admin", userHandler.ListUsers)))
	mux.HandleFunc("POST /api/v1/admin/users", withAuth(tokenManager, requireRole("admin", userHandler.CreateUser)))
	mux.HandleFunc("GET /api/v1/admin/users/{id}", withAuth(tokenManager, requireRole("admin", userHandler.GetUser)))
	mux.HandleFunc("PUT /api/v1/admin/users/{id}", withAuth(tokenManager, requireRole("admin", userHandler.UpdateUser)))
	mux.HandleFunc("DELETE /api/v1/admin/users/{id}", withAuth(tokenManager, requireRole("admin", userHandler.DeleteUser)))
	mux.HandleFunc("GET /api/v1/admin/flowers", withAuth(tokenManager, requireRole("admin", flowerHandler.ListFlowers)))
	mux.HandleFunc("POST /api/v1/admin/flowers", withAuth(tokenManager, requireRole("admin", flowerHandler.CreateFlower)))
	mux.HandleFunc("PUT /api/v1/admin/flowers/{id}", withAuth(tokenManager, requireRole("admin", flowerHandler.UpdateFlower)))
	mux.HandleFunc("GET /api/v1/admin/banners", withAuth(tokenManager, requireRole("admin", bannerHandler.ListBanners)))
	mux.HandleFunc("POST /api/v1/admin/banners", withAuth(tokenManager, requireRole("admin", bannerHandler.CreateBanner)))
	mux.HandleFunc("PUT /api/v1/admin/banners/{id}", withAuth(tokenManager, requireRole("admin", bannerHandler.UpdateBanner)))
	mux.HandleFunc("POST /api/v1/admin/users/{id}/operator-chat", withAuth(tokenManager, requireRole("admin", chatHandler.EnsureAdminRoomForUser)))
	mux.HandleFunc("GET /api/v1/admin/chat-rooms", withAuth(tokenManager, requireRole("admin", chatHandler.ListAdminRooms)))
	mux.HandleFunc("GET /api/v1/admin/chat-rooms/{id}", withAuth(tokenManager, requireRole("admin", chatHandler.GetRoomDetail)))
	mux.HandleFunc("POST /api/v1/admin/chat-rooms/{id}/messages", withAuth(tokenManager, requireRole("admin", chatHandler.CreateMessage)))
	mux.HandleFunc("POST /api/v1/users", userHandler.CreateUser)
	mux.HandleFunc("GET /api/v1/users/me", withAuth(tokenManager, userHandler.Me))
	mux.HandleFunc("GET /api/v1/users/{id}", withAuth(tokenManager, userHandler.GetUser))
	mux.HandleFunc("PUT /api/v1/users/{id}", withAuth(tokenManager, userHandler.UpdateUser))
	mux.HandleFunc("DELETE /api/v1/users/{id}", withAuth(tokenManager, userHandler.DeleteUser))
	mux.HandleFunc("GET /api/v1/chat-rooms", withAuth(tokenManager, chatHandler.ListUserRooms))
	mux.HandleFunc("POST /api/v1/chat-direct/{id}", withAuth(tokenManager, chatHandler.EnsureDirectRoom))
	mux.HandleFunc("GET /api/v1/chat-rooms/{id}", withAuth(tokenManager, chatHandler.GetRoomDetail))
	mux.HandleFunc("POST /api/v1/chat-rooms/{id}/messages", withAuth(tokenManager, chatHandler.CreateMessage))
	mux.HandleFunc("POST /api/v1/auth/login", userHandler.Login)
	mux.HandleFunc("POST /api/v1/auth/refresh", userHandler.Refresh)
	mux.HandleFunc("POST /api/v1/auth/logout", userHandler.Logout)

	return mux
}
