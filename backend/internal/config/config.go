package config

import "os"

type Config struct {
	AppEnv         string
	Port           string
	AllowedOrigins string
	DatabaseURL    string
	JWTSecret      string
}

func Load() Config {
	return Config{
		AppEnv:         envOrDefault("APP_ENV", "development"),
		Port:           envOrDefault("PORT", "8080"),
		AllowedOrigins: envOrDefault("ALLOWED_ORIGINS", "http://localhost:5173,http://localhost:3000"),
		DatabaseURL:    envOrDefault("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/date_app?sslmode=disable"),
		JWTSecret:      envOrDefault("JWT_SECRET", "change-me-in-production"),
	}
}

func envOrDefault(key, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}
