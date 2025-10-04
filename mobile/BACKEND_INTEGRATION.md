# Backend Integration Guide

This Flutter app is now fully integrated with the FastAPI backend located in `backend/`.

## Quick Start

### Production (Default)

The app connects to the production backend at `https://backend.thala.app` by default.

```bash
cd mobile
flutter run -d macos
```

### Local Development

#### 1. Start the Backend Stack

```bash
# From project root
docker-compose up -d

# Or run backend directly
cd backend
uvicorn thala_backend.main:app --reload
```

The backend will start on `http://localhost:8000`

#### 2. Run the Flutter App with Local Backend

```bash
cd mobile

# Using the helper script (recommended)
./run_local.sh -- -d macos

# Or manually connect to local backend
flutter run -d macos --dart-define THELA_API_URL=http://localhost:8000

# Or for custom backend URL
flutter run -d macos --dart-define THELA_API_URL=http://your-server:8000
```

## Features

### Authentication
- ✅ **Email/Password Registration**: New users can create accounts
- ✅ **Email/Password Login**: Existing users can sign in
- ✅ **Session Persistence**: Tokens are stored locally and refreshed automatically
- ✅ **Google Sign-In**: OAuth flow integrated (requires setup)
- ✅ **Warm Splash Screen**: Community-focused welcome experience
- ✅ **Beautiful Auth UI**: Animated login/register screens with warm design

### API Integration
- ✅ **Backend Auth Service**: Handles all authentication with FastAPI
- ✅ **API Client**: Generic HTTP client for all backend communication
- ✅ **Token Management**: Automatic token refresh and storage
- ✅ **Error Handling**: User-friendly error messages

## Configuration

### Backend URL

**Default (Production)**: `https://backend.thala.app`

To override for local development or custom servers:

**Option 1: dart-define (Recommended)**
```bash
# Local development
flutter run --dart-define THELA_API_URL=http://localhost:8000

# Custom server
flutter run --dart-define THELA_API_URL=https://your-server.com
```

**Option 2: Code Edit (Permanent)**
Edit `lib/services/backend_auth_service.dart` and `lib/services/api_client.dart`:
```dart
static const String _defaultApiUrl = 'http://localhost:8000';
```

### Database Setup

The backend automatically creates database tables on first run. Just ensure you have a PostgreSQL database configured:

```bash
# In backend/.env
DATABASE_URL=postgresql://user:password@localhost:5432/thala
JWT_SECRET=your-secret-key-here
GOOGLE_OAUTH_CLIENT_ID=your-google-client-id
```

## API Endpoints Used

The app communicates with these backend endpoints:

### Authentication
- `POST /api/v1/auth/register` - Create new user account
- `POST /api/v1/auth/login` - Email/password login
- `POST /api/v1/auth/google` - Google OAuth login
- `POST /api/v1/auth/refresh` - Refresh access token
- `GET /api/v1/auth/me` - Get current user profile

### Data (Coming Soon)
- `/api/v1/videos` - Video feed content
- `/api/v1/music` - Music tracks and playlists
- `/api/v1/events` - Cultural events
- `/api/v1/community` - Community profiles and posts
- `/api/v1/search` - MeiliSearch integration

## Architecture

```
mobile/
├── lib/
│   ├── features/
│   │   ├── splash/         # Warm splash screen
│   │   └── auth/           # Login/register UI
│   ├── controllers/
│   │   └── auth_controller.dart  # Auth state management
│   ├── services/
│   │   ├── backend_auth_service.dart  # Auth API calls
│   │   └── api_client.dart            # Generic HTTP client
│   └── main.dart
├── run_local.sh            # Helper script for local development
└── BACKEND_INTEGRATION.md  # This file
```

## Testing

### Manual Testing (Production)

1. **Run App** (connects to backend.thala.app):
   ```bash
   cd mobile && flutter run -d macos
   ```

2. **Test Registration**:
   - Open app → See splash screen
   - Click "Sign up"
   - Fill in name, email, password
   - Click "Create account"
   - Should authenticate and see onboarding

3. **Test Login**:
   - Sign out from profile
   - Sign in with same credentials
   - Should authenticate without onboarding

### Manual Testing (Local Backend)

1. **Start Local Backend**:
   ```bash
   # From project root
   docker-compose up -d
   # Or: cd backend && uvicorn thala_backend.main:app --reload
   ```

2. **Run App with Local Backend**:
   ```bash
   cd mobile && ./run_local.sh -- -d macos
   # Or: flutter run -d macos --dart-define THELA_API_URL=http://localhost:8000
   ```

3. **Test as above**

### Backend Logs

The FastAPI backend logs all requests. Check terminal for:
```
INFO: POST /api/v1/auth/register
INFO: Database schema initialized successfully
```

## Troubleshooting

### "Network error. Please check your connection."
- **Production**: Check if backend.thala.app is online
- **Local Dev**: Ensure backend is running on port 8000
- Check firewall/network settings
- Verify `THELA_API_URL` is correct if using custom URL

### "Email already registered"
- User already exists in database
- Either login or use different email

### Database errors
- Check PostgreSQL is running
- Verify `DATABASE_URL` in backend/.env
- Check backend logs for migration errors

## Next Steps

- [ ] Implement Google Sign-In platform setup
- [ ] Connect video feed to `/api/v1/videos`
- [ ] Connect music player to `/api/v1/music`
- [ ] Implement real-time messaging
- [ ] Add file upload for user content
