# Thala Mobile App

Thala is a TikTok-inspired home for Amazigh stories, culture, and music. The mobile app includes:

- A vertical video feed with bilingual overlays and backend-synced content (falls back to curated samples).
- A shader-driven onboarding splash that greets new users and gathers Amazigh identity or ally context.
- Dedicated community and archive spaces to surface gatherings, projects, and cultural artefacts.
- A music lounge with a live shader visualiser that pulses with curated Amazigh tracks.
- A rights & safety page describing the copyright takedown workflow.

## Getting started

1. Install dependencies

   ```bash
   flutter pub get
   ```

2. (Optional) Connect to a backend. The app works offline with sample data, but to sync real content:

   ```bash
   # Start the backend (in a separate terminal)
   cd ../backend
   docker-compose up -d  # Or run backend directly

   # Run the mobile app with local backend
   ./run_local.sh -- -d macos
   ```

   Or manually specify the backend URL:

   ```bash
   flutter run -d macos --dart-define THELA_API_URL=http://localhost:8000
   ```

   Without a backend connection, the app gracefully falls back to curated sample content.

3. Launch the app. Onboarding appears once per runtime and then drops you into the home shell with tabs for Feed, Community, Archive, Music, and Rights.

## Shader notes

- Two custom fragment shaders ship with the app:
  - `shaders/splash_intro.frag` powers the onboarding aura.
  - `shaders/amazigh_wave.frag` powers the music visualiser.
- Ensure you are running on Flutter 3.10+ with Impeller enabled (default on iOS and macOS). For Android, enable `flutter run --enable-impeller` if you hit shader issues.

## Development tips

- The app connects to the backend via `ApiClient` when `THELA_API_URL` is provided, otherwise uses sample data.
- Authentication is handled by `BackendAuthService` with automatic token refresh.
- To refresh the video feed manually, tap the refresh icon in the header.
- All assets and shaders are registered in `pubspec.yaml`.
- See `BACKEND_INTEGRATION.md` for full backend integration details.
