package domain

type Session struct {
	ID        string
	UserID    string
	TokenHash string
	ExpiresAt string
	RevokedAt string
}

type AuthTokens struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
	TokenType    string `json:"tokenType"`
	ExpiresIn    int64  `json:"expiresIn"`
}

type AuthResponse struct {
	User   User       `json:"user"`
	Tokens AuthTokens `json:"tokens"`
}
