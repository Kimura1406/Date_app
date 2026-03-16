package domain

type Profile struct {
	ID        string   `json:"id"`
	Name      string   `json:"name"`
	Age       int      `json:"age"`
	Job       string   `json:"job"`
	Bio       string   `json:"bio"`
	Distance  string   `json:"distance"`
	Interests []string `json:"interests"`
}

type Match struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	LastMessage string `json:"lastMessage"`
	LastSeen    string `json:"lastSeen"`
	Status      string `json:"status"`
}

type User struct {
	ID        string   `json:"id"`
	Email     string   `json:"email"`
	Role      string   `json:"role"`
	Name      string   `json:"name"`
	Age       int      `json:"age"`
	Job       string   `json:"job"`
	Bio       string   `json:"bio"`
	Distance  string   `json:"distance"`
	Interests []string `json:"interests"`
	CreatedAt string   `json:"createdAt"`
	UpdatedAt string   `json:"updatedAt"`
}

type UserCredentials struct {
	ID           string
	Email        string
	Role         string
	PasswordHash string
}
