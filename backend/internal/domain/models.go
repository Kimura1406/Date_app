package domain

type Profile struct {
	ID        string   `json:"id"`
	Name      string   `json:"name"`
	Age       int      `json:"age"`
	Job       string   `json:"job"`
	Bio       string   `json:"bio"`
	Distance  string   `json:"distance"`
	Interests []string `json:"interests"`
	Country   string   `json:"country"`
	Gender    string   `json:"gender"`
	Location  string   `json:"location"`
	ImageURL  string   `json:"imageUrl"`
	IsNew     bool     `json:"isNew"`
}

type DiscoveryFilter struct {
	Country  string
	Job      string
	MinAge   int
	MaxAge   int
	Gender   string
	Location string
}

type Match struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	LastMessage string `json:"lastMessage"`
	LastSeen    string `json:"lastSeen"`
	Status      string `json:"status"`
}

type ChatParticipant struct {
	UserID   string `json:"userId"`
	Name     string `json:"name"`
	Role     string `json:"role"`
	IsSender bool   `json:"isSender,omitempty"`
}

type ChatMessage struct {
	ID          string          `json:"id"`
	RoomID      string          `json:"roomId"`
	SenderID    string          `json:"senderId"`
	SenderName  string          `json:"senderName"`
	Body        string          `json:"body"`
	SentAt      string          `json:"sentAt"`
	Participant ChatParticipant `json:"participant"`
}

type ChatRoomSummary struct {
	RoomID        string            `json:"roomId"`
	RoomType      string            `json:"roomType"`
	Participants  []ChatParticipant `json:"participants"`
	LastMessage   string            `json:"lastMessage"`
	LastMessageAt string            `json:"lastMessageAt"`
}

type ChatRoomDetail struct {
	RoomID       string            `json:"roomId"`
	RoomType     string            `json:"roomType"`
	Participants []ChatParticipant `json:"participants"`
	Messages     []ChatMessage     `json:"messages"`
}

type User struct {
	ID           string   `json:"id"`
	Email        string   `json:"email"`
	Role         string   `json:"role"`
	Name         string   `json:"name"`
	Age          int      `json:"age"`
	Job          string   `json:"job"`
	Bio          string   `json:"bio"`
	Distance     string   `json:"distance"`
	Interests    []string `json:"interests"`
	BirthDate    string   `json:"birthDate"`
	Country      string   `json:"country"`
	Prefecture   string   `json:"prefecture"`
	DatingReason string   `json:"datingReason"`
	CreatedAt    string   `json:"createdAt"`
	UpdatedAt    string   `json:"updatedAt"`
}

type UserCredentials struct {
	ID           string
	Email        string
	Role         string
	PasswordHash string
}
