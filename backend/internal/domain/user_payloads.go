package domain

type CreateUserInput struct {
	Email     string   `json:"email"`
	Password  string   `json:"password"`
	Name      string   `json:"name"`
	Age       int      `json:"age"`
	Job       string   `json:"job"`
	Bio       string   `json:"bio"`
	Distance  string   `json:"distance"`
	Interests []string `json:"interests"`
}

type UpdateUserInput struct {
	Email     string   `json:"email"`
	Password  string   `json:"password"`
	Name      string   `json:"name"`
	Age       int      `json:"age"`
	Job       string   `json:"job"`
	Bio       string   `json:"bio"`
	Distance  string   `json:"distance"`
	Interests []string `json:"interests"`
}

type LoginInput struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type RefreshInput struct {
	RefreshToken string `json:"refreshToken"`
}

type LogoutInput struct {
	RefreshToken string `json:"refreshToken"`
}
