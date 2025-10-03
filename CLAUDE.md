# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Thela** (also spelled "Thala") is a TikTok-inspired cultural platform for Amazigh stories, music, and community. The project consists of three main components:

- **app/** - Flutter mobile application (iOS/Android)
- **backend/** - FastAPI backend with PostgreSQL and S3 integration
- **landing/** - Next.js landing page

## Development Commands

### Flutter App (app/)

**Setup:**
```bash
cd app
flutter pub get
```

**Run with Supabase credentials:**
```bash
# Using the helper script (reads from .env.local)
./tools/run_with_supabase.sh -- -d macos

# Or manually with dart-define flags
flutter run \
  --dart-define SUPABASE_URL=https://your-project.supabase.co \
  --dart-define SUPABASE_PUBLISHABLE_KEY=your-key \
  -d macos
```

**Run without Supabase (uses sample data):**
```bash
cd app
flutter run -d macos
```

**Testing:**
```bash
cd app
flutter test                    # Run all tests
flutter test test/specific_test.dart  # Run specific test
```

**Build:**
```bash
cd app
flutter build ios              # iOS build
flutter build apk              # Android APK
flutter build macos            # macOS build
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
uvicorn thela_backend.main:app --reload
```

**Configuration:**
- All settings are loaded from environment variables (see `thela_backend/core/config.py`)
- Required: `DATABASE_URL`, `GOOGLE_OAUTH_CLIENT_ID`, `JWT_SECRET`
- Optional: AWS S3 credentials, CORS origins

**Testing:**
```bash
cd backend
pytest                         # No tests currently configured
```

### Landing Page (landing/)

**Setup:**
```bash
cd landing
npm install
```

**Development:**
```bash
cd landing
npm run dev                    # Start dev server (uses Turbopack)
```

**Build:**
```bash
cd landing
npm run build                  # Production build (uses Turbopack)
npm start                      # Start production server
```

**Linting:**
```bash
cd landing
npm run lint
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
- Supabase integration is optional; app gracefully degrades to samples when unavailable
- MeiliSearch integration for search (optional, similar fallback pattern)

**Service initialization:**
- `SupabaseManager.ensureInitialized()` - Checks for dart-define credentials
- `MeiliSearchManager.ensureInitialized()` - Initializes search client
- Both called in `main.dart` before app starts

### Backend Architecture

FastAPI-based backend replacing Supabase functionality:

**Directory structure:**
- `src/thela_backend/api/` - API routes and dependencies
- `src/thela_backend/core/` - Core configuration and settings
- `src/thela_backend/db/` - Database models and session management
- `src/thela_backend/models/` - SQLAlchemy models
- `src/thela_backend/schemas/` - Pydantic schemas for validation
- `src/thela_backend/services/` - Business logic services

**Key components:**
- Google OAuth authentication with JWT tokens
- PostgreSQL persistence via SQLAlchemy async
- S3 media storage integration (optional)
- CORS configuration for cross-origin requests

**Main entry point:**
- `src/thela_backend/main.py` - Creates FastAPI app and includes routers
- API routes mounted at `/api/v1` (configurable via `API_V1_PREFIX`)

### Database Schema

The app expects specific Supabase/PostgreSQL tables:

**Main tables:**
- `videos` - Video posts with bilingual metadata (title, description, location in EN/FR)
- `music_tracks` - Music catalog with artwork and preview URLs
- `video_effects` - Visual effects with JSON config
- Additional tables defined in `app/schema.sql`

**Important columns:**
- Videos: `creator_handle`, `creator_name_en/fr`, `tags` (text array), engagement counts
- All tables have RLS policies for read access
- See `app/schema.sql` for complete schema

## Environment Configuration

### Flutter App

**Required for Supabase:**
- Create `app/.env.local` (gitignored):
  ```
  SUPABASE_URL=https://your-project.supabase.co
  SUPABASE_ANON_KEY=your-publishable-key
  ```
- Or pass via `--dart-define` flags when running

**MeiliSearch (optional):**
- Configured via dart-define or hardcoded in `meili_search_manager.dart`

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
- **Graceful degradation**: App works with sample data when Supabase/MeiliSearch unavailable
- **Bilingual support**: Content has EN/FR variants throughout (models use `LocalizedText`)
- **Asset management**: Videos and images registered in `pubspec.yaml` under `assets:`
- **Custom shaders**: Located in `shaders/` directory, compiled at build time
