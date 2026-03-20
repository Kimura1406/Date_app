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
	Country       string
	Job           string
	MinAge        int
	MaxAge        int
	Gender        string
	Location      string
	ExcludeUserID string
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
	PointBalance int      `json:"pointBalance"`
	CreatedAt    string   `json:"createdAt"`
	LastLoginAt  string   `json:"lastLoginAt"`
	UpdatedAt    string   `json:"updatedAt"`
}

type UserCredentials struct {
	ID           string
	Email        string
	Role         string
	PasswordHash string
}

type UserLikeSummary struct {
	TargetUserID string `json:"targetUserId"`
	LikeCount    int    `json:"likeCount"`
	LikedByMe    bool   `json:"likedByMe"`
}

type UserLiker struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	BirthDate string `json:"birthDate"`
	Country   string `json:"country"`
	LikedAt   string `json:"likedAt"`
}

type BlockedUser struct {
	ID        string `json:"id"`
	Name      string `json:"name"`
	BirthDate string `json:"birthDate"`
	Country   string `json:"country"`
	BlockedAt string `json:"blockedAt"`
}

type UserReportInput struct {
	Reason string `json:"reason"`
}

type UserReportEntry struct {
	ID               string `json:"id"`
	ReporterUserID   string `json:"reporterUserId"`
	ReporterUserName string `json:"reporterUserName"`
	Reason           string `json:"reason"`
	CreatedAt        string `json:"createdAt"`
}

type ReportedUserSummary struct {
	ID                   string            `json:"id"`
	ReportedUserID       string            `json:"reportedUserId"`
	ReportedUserName     string            `json:"reportedUserName"`
	LatestReporterUserID string            `json:"latestReporterUserId"`
	LatestReporterName   string            `json:"latestReporterName"`
	LatestReason         string            `json:"latestReason"`
	LatestReportedAt     string            `json:"latestReportedAt"`
	Reports              []UserReportEntry `json:"reports"`
}

type UserPointGrantInput struct {
	Points int `json:"points"`
}

type Flower struct {
	ID             string `json:"id"`
	Name           string `json:"name"`
	ImageURL       string `json:"imageUrl"`
	Description    string `json:"description"`
	PricePoints    int    `json:"pricePoints"`
	PurchaserCount int    `json:"purchaserCount"`
	PurchaseCount  int    `json:"purchaseCount"`
	Published      bool   `json:"published"`
	CreatedAt      string `json:"createdAt"`
	UpdatedAt      string `json:"updatedAt"`
}

type CreateFlowerInput struct {
	Name        string `json:"name"`
	ImageURL    string `json:"imageUrl"`
	Description string `json:"description"`
	PricePoints int    `json:"pricePoints"`
	Published   bool   `json:"published"`
}

type UpdateFlowerInput struct {
	Name        string `json:"name"`
	ImageURL    string `json:"imageUrl"`
	Description string `json:"description"`
	PricePoints int    `json:"pricePoints"`
	Published   bool   `json:"published"`
}

type FlowerAcquireResult struct {
	Flower      Flower `json:"flower"`
	User        User   `json:"user"`
	OwnedCount  int    `json:"ownedCount"`
	SpentPoints int    `json:"spentPoints"`
}

type OwnedFlowerItem struct {
	Flower       Flower  `json:"flower"`
	OwnedCount   int     `json:"ownedCount"`
	LastOwnedAt  string  `json:"lastOwnedAt"`
	ReceivedFrom *string `json:"receivedFrom,omitempty"`
}

type MyFlowersResponse struct {
	Purchased []OwnedFlowerItem `json:"purchased"`
	Gifted    []OwnedFlowerItem `json:"gifted"`
}

type Banner struct {
	ID           string `json:"id"`
	ImageURL     string `json:"imageUrl"`
	EventName    string `json:"eventName"`
	DisplayOrder int    `json:"displayOrder"`
	RedirectLink string `json:"redirectLink"`
	Published    bool   `json:"published"`
	CreatedAt    string `json:"createdAt"`
	UpdatedAt    string `json:"updatedAt"`
}

type CreateBannerInput struct {
	ImageURL     string `json:"imageUrl"`
	EventName    string `json:"eventName"`
	DisplayOrder int    `json:"displayOrder"`
	RedirectLink string `json:"redirectLink"`
	Published    bool   `json:"published"`
}

type UpdateBannerInput struct {
	ImageURL     string `json:"imageUrl"`
	EventName    string `json:"eventName"`
	DisplayOrder int    `json:"displayOrder"`
	RedirectLink string `json:"redirectLink"`
	Published    bool   `json:"published"`
}
