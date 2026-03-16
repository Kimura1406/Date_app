package httpapi

import (
	"context"
	"net/http"
	"strings"

	backendauth "github.com/kimura/dating/backend/internal/auth"
)

type authContextKey string

const claimsContextKey authContextKey = "auth_claims"

func withAuth(tokenManager *backendauth.TokenManager, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tokenString := extractBearerToken(r.Header.Get("Authorization"))
		if tokenString == "" {
			writeError(w, http.StatusUnauthorized, "missing bearer token")
			return
		}

		claims, err := tokenManager.ParseToken(tokenString)
		if err != nil {
			writeError(w, http.StatusUnauthorized, "invalid token")
			return
		}

		ctx := context.WithValue(r.Context(), claimsContextKey, claims)
		next(w, r.WithContext(ctx))
	}
}

func requireRole(role string, next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		claims, ok := authClaimsFromContext(r.Context())
		if !ok || claims.Role != role {
			writeError(w, http.StatusForbidden, "forbidden")
			return
		}

		next(w, r)
	}
}

func authClaimsFromContext(ctx context.Context) (*backendauth.Claims, bool) {
	claims, ok := ctx.Value(claimsContextKey).(*backendauth.Claims)
	return claims, ok
}

func extractBearerToken(header string) string {
	const prefix = "Bearer "
	if !strings.HasPrefix(header, prefix) {
		return ""
	}
	return strings.TrimSpace(strings.TrimPrefix(header, prefix))
}
