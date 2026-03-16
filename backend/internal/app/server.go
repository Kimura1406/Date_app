package app

import (
	"database/sql"
	"fmt"
	"net/http"
	"strings"
	"time"

	backendauth "github.com/kimura/dating/backend/internal/auth"
	"github.com/kimura/dating/backend/internal/config"
	"github.com/kimura/dating/backend/internal/database"
	"github.com/kimura/dating/backend/internal/httpapi"
	"github.com/kimura/dating/backend/internal/repository"
	"github.com/kimura/dating/backend/internal/service"
)

type Server struct {
	Config     config.Config
	db         *sql.DB
	httpServer *http.Server
}

func NewServer() (*Server, error) {
	cfg := config.Load()

	db, err := database.Open(cfg.DatabaseURL)
	if err != nil {
		return nil, err
	}

	if err := database.Migrate(db); err != nil {
		_ = db.Close()
		return nil, err
	}

	if err := database.Seed(db); err != nil {
		_ = db.Close()
		return nil, err
	}

	tokenManager := backendauth.NewTokenManager(cfg.JWTSecret, 24*time.Hour)

	router := httpapi.NewRouter(
		cfg,
		service.NewProfileService(repository.NewProfileRepository(db)),
		service.NewMatchService(repository.NewMatchRepository(db)),
		service.NewUserService(
			repository.NewUserRepository(db),
			repository.NewSessionRepository(db),
			tokenManager,
			30*24*time.Hour,
		),
		tokenManager,
	)

	server := &http.Server{
		Addr:              fmt.Sprintf(":%s", cfg.Port),
		Handler:           corsMiddleware(strings.Split(cfg.AllowedOrigins, ","), router),
		ReadHeaderTimeout: 5 * time.Second,
	}

	return &Server{
		Config:     cfg,
		db:         db,
		httpServer: server,
	}, nil
}

func (s *Server) Start() error {
	return s.httpServer.ListenAndServe()
}

func (s *Server) Close() error {
	if s.db == nil {
		return nil
	}

	return s.db.Close()
}
