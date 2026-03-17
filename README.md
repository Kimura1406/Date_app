# Date app

Monorepo starter for a dating application with:

- `mobile/`: Flutter mobile app
- `backend/`: Golang REST API
- `admin/`: Node.js admin dashboard with React + Vite

## Structure

```text
Date app/
|-- admin/
|-- backend/
|-- mobile/
`-- README.md
```

## Stack

- Flutter for the user mobile app
- Go for backend APIs
- Node.js with React for admin tools

## Features In This Starter

- discovery screen
- matches screen
- profile setup screen
- backend healthcheck
- sample discovery and match APIs
- admin moderation dashboard shell

## Requirements

- Flutter SDK 3.24+
- Go 1.22+
- Node.js 20+

## Run

### Mobile

```bash
cd mobile
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

### Backend

```bash
cd backend
go mod tidy
go run ./cmd/api
```

### Admin

```bash
cd admin
npm install
npm run dev
```

## CI

GitHub Actions now builds:

- `backend/` with Go
- `admin/` with Node.js + Vite

## Deploy

This repo includes a Render Blueprint in `render.yaml` for:

- `date-app-backend` as a Go web service
- `date-app-admin` as a static site
- `date-app-db` as PostgreSQL

To deploy on Render:

1. Sign in to Render and connect your GitHub account.
2. Create a new Blueprint and select this repository.
3. Render will read `render.yaml` from the repo root and provision backend, admin, and database together.
4. After deploy finishes, open the admin site URL and sign in with the seeded admin account.

### One-click deploy from GitHub Actions

This repo also includes a manual GitHub Actions workflow in `.github/workflows/deploy-render.yml`.

Set these repository secrets once in GitHub:

- `RENDER_BACKEND_DEPLOY_HOOK_URL`
- `RENDER_ADMIN_DEPLOY_HOOK_URL`

After that, deploy is just:

1. Open the `Actions` tab in GitHub.
2. Choose `Deploy Render`.
3. Click `Run workflow`.
4. Pick `all`, `backend`, or `admin`.

## Next Steps

1. Add likes, matches, messages, and reports.
2. Add image upload and moderation.
3. Persist auth state securely on mobile and admin.
4. Deploy mobile, backend, and admin separately.

## Database

The backend now uses PostgreSQL for discovery and match data.

### Start PostgreSQL

```bash
docker compose up -d postgres
```

## Project Notes

- Docs index: [docs/README.md](./docs/README.md)
- Vietnamese setup history: [docs/lich-su-thiet-lap-du-an.md](./docs/lich-su-thiet-lap-du-an.md)
- English setup history: [docs/dev-setup-history.md](./docs/dev-setup-history.md)

### Backend env

```bash
DATABASE_URL=postgres://postgres:postgres@localhost:5432/date_app?sslmode=disable
JWT_SECRET=change-me-in-production
```

### What happens on startup

- The API connects to PostgreSQL.
- SQL migrations in `backend/internal/database/migrations` run automatically.
- Sample profiles, matches, one demo user, and one demo admin are seeded if the tables are empty.

## User APIs

Admin routes:

- `POST /api/v1/admin/auth/login`
- `GET /api/v1/admin/users`
- `POST /api/v1/admin/users`
- `GET /api/v1/admin/users/{id}`
- `PUT /api/v1/admin/users/{id}`
- `DELETE /api/v1/admin/users/{id}`

App routes:

- `POST /api/v1/users`
- `GET /api/v1/users/me`
- `PUT /api/v1/users/{id}`
- `DELETE /api/v1/users/{id}`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`

Demo login:

- `email`: `lina@example.com`
- `password`: `password123`

Demo admin login:

- `email`: `admin@kimura.local`
- `password`: `admin12345`

## Auth behavior

- `POST /api/v1/admin/auth/login` only issues a token for accounts with role `admin`.
- `POST /api/v1/auth/login` issues a token for regular app users.
- `POST /api/v1/auth/refresh` rotates the refresh token and returns a fresh access token.
- `POST /api/v1/auth/logout` revokes the submitted refresh token.
- Admin user CRUD routes require `Authorization: Bearer <token>`.
- App `update/delete/get me` routes require a valid token, and non-admin users can only access their own account.
- Admin auth state is persisted in browser `localStorage`.
- Mobile auth state is persisted with `flutter_secure_storage`.
