# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Thala** is a TikTok-inspired cultural platform for Amazigh stories, music, and community. The project consists of four main components:

- **mobile/** - Flutter mobile application (iOS/Android/Web/Desktop)
- **backend/** - FastAPI backend with PostgreSQL and S3 integration
- **web/** - Next.js landing page
- **admin/** - Admin dashboard (Next.js)

## Development Commands

### Flutter App (mobile/)

**Setup:**
```bash
cd mobile
flutter pub get
```

**Run with backend:**
```bash
# Using the helper script (reads from .env.local)
./run_local.sh -- -d macos

# Or manually with dart-define flags
flutter run \
  --dart-define BACKEND_URL=http://localhost:8000 \
  -d macos
```

**Run without backend (uses sample data):**
```bash
cd mobile
flutter run -d macos
```

**Testing:**
```bash
cd mobile
flutter test                    # Run all tests
flutter test test/specific_test.dart  # Run specific test
```

**Build:**
```bash
cd mobile
flutter build ios              # iOS build
flutter build apk              # Android APK
flutter build macos            # macOS build
flutter build web              # Web build
```

**Shader compilation notes:**
- Requires Flutter 3.10+ with Impeller enabled (default on iOS/macOS)
- For Android: `flutter run --enable-impeller`
- Shaders are located in `shaders/` and registered in `pubspec.yaml`

### Backend (backend/)

**Setup:**
```bash
cd backend
uv pip install -e .            # Install in editable mode
# OR
pip install -e .
```

**Run development server:**
```bash
cd backend
uvicorn thala_backend.main:app --reload
```

**Configuration:**
- All settings are loaded from environment variables (see `thala_backend/core/config.py`)
- Required: `DATABASE_URL`, `GOOGLE_OAUTH_CLIENT_ID`, `JWT_SECRET`
- Optional: AWS S3 credentials, CORS origins

**Testing:**
```bash
cd backend
pytest                         # No tests currently configured
```

### Landing Page (web/)

**Setup:**
```bash
cd web
npm install
```

**Development:**
```bash
cd web
npm run dev                    # Start dev server (uses Turbopack)
```

**Build:**
```bash
cd web
npm run build                  # Production build (uses Turbopack)
npm start                      # Start production server
```

**Linting:**
```bash
cd web
npm run lint
```

### Admin Dashboard (admin/)

**Setup:**
```bash
cd admin
npm install
```

**Development:**
```bash
cd admin
npm run dev                    # Start dev server
```

**Build:**
```bash
cd admin
npm run build                  # Production build
npm start                      # Start production server
```

## Architecture

### Flutter App Architecture

The app follows a **feature-based structure** with clear separation of concerns:

**Directory structure:**
- `lib/features/` - Feature modules (feed, music, events, community, etc.)
- `lib/controllers/` - State management (ChangeNotifier-based)
- `lib/data/` - Repositories and data sources (both sample and Supabase-backed)
- `lib/models/` - Data models
- `lib/services/` - Shared services (Supabase, MeiliSearch, recommendations)
- `lib/ui/` - Shared UI components
- `lib/app/` - App-level configuration (theme, navigation shell)

**Key features:**
- `feed/` - Vertical video feed with bilingual overlays
- `music/` - Music player with shader-based visualizer
- `events/` - Cultural events discovery
- `community/` - Community profiles and spaces
- `search/` - MeiliSearch-powered content discovery
- `onboarding/` - Shader-driven onboarding flow

**State management:**
- Uses `provider` package with ChangeNotifier controllers
- Controllers are scoped to features and provided via MultiProvider
- Main shell in `lib/app/home_shell.dart` manages tab navigation and top-level controllers

**Data layer strategy:**
- Repositories provide a unified interface to both sample and remote data
- Sample data files in `lib/data/sample_*.dart` provide fallback content
- Backend integration is optional; app gracefully degrades to samples when unavailable
- Search functionality integrated via backend API

**Service initialization:**
- `ApiClient` - Manages backend communication with automatic retry
- `BackendAuthService` - Handles Google OAuth and JWT tokens
- Services initialized in `main.dart` with fallback to sample data

### Backend Architecture

FastAPI-based backend replacing Supabase functionality:

**Directory structure:**
- `src/thala_backend/api/` - API routes and dependencies
- `src/thala_backend/core/` - Core configuration and settings
- `src/thala_backend/db/` - Database models and session management
- `src/thala_backend/models/` - SQLAlchemy models
- `src/thala_backend/schemas/` - Pydantic schemas for validation
- `src/thala_backend/services/` - Business logic services

**Key components:**
- Google OAuth authentication with JWT tokens
- PostgreSQL persistence via SQLAlchemy async
- S3 media storage integration (optional)
- CORS configuration for cross-origin requests

**Main entry point:**
- `src/thala_backend/main.py` - Creates FastAPI app and includes routers
- API routes mounted at `/api/v1` (configurable via `API_V1_PREFIX`)

### Database Schema

The app expects specific Supabase/PostgreSQL tables:

**Main tables:**
- `videos` - Video posts with bilingual metadata (title, description, location in EN/FR)
- `music_tracks` - Music catalog with artwork and preview URLs
- `video_effects` - Visual effects with JSON config
- Additional tables defined in backend migrations

**Important columns:**
- Videos: `creator_handle`, `creator_name_en/fr`, `tags` (text array), engagement counts
- All tables have proper indexes and constraints
- See `backend/alembic/` for database migrations

## Environment Configuration

### Flutter App

**Backend connection:**
- Create `mobile/.env.local` (gitignored):
  ```
  BACKEND_URL=http://localhost:8000
  GOOGLE_OAUTH_CLIENT_ID=your-client-id
  ```
- Or pass via `--dart-define` flags when running
- App falls back to sample data when backend is unavailable

### Backend

**Environment variables (required):**
- `DATABASE_URL` - PostgreSQL connection string
- `GOOGLE_OAUTH_CLIENT_ID` - Google OAuth client ID
- `JWT_SECRET` - Secret for JWT signing

**Optional:**
- `AWS_REGION`, `AWS_S3_BUCKET`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- `S3_ENDPOINT_URL` - For S3-compatible storage
- `CORS_ALLOWED_ORIGINS` - Comma-separated list of allowed origins

## Important Notes

- **Never commit credentials**: Use `.env.local` (gitignored) for secrets
- **Shader compatibility**: Requires Flutter 3.10+ with Impeller for shaders
- **Graceful degradation**: App works with sample data when backend unavailable
- **Bilingual support**: Content has EN/FR variants throughout (models use `LocalizedText`)
- **Asset management**: Videos and images registered in `pubspec.yaml` under `assets:`
- **Custom shaders**: Located in `mobile/shaders/` directory, compiled at build time
- **Monorepo structure**: Use `docker-compose.yml` for local development stack
