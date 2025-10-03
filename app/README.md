# Thala

Thala is a TikTok-inspired home for Amazigh stories, culture, and music. The experience now includes:

- A vertical video feed with bilingual overlays and Supabase-backed content (falls back to curated samples).
- A shader-driven onboarding splash that greets new users and gathers Amazigh identity or ally context.
- Dedicated community and archive spaces to surface gatherings, projects, and cultural artefacts.
- A music lounge with a live shader visualiser that pulses with curated Amazigh tracks.
- A rights & safety page describing the copyright takedown workflow.

## Getting started

1. Install dependencies

   ```bash
   flutter pub get
   ```

2. (Optional) Wire up Supabase so the feed can stream real data. Keep the credentials out of git by creating `.env.local` (ignored) with your values:

   ```dotenv
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-publishable-key
   ```

   Then start the app through the helper script so the values are passed as `--dart-define`s:

   ```bash
   ./tools/run_with_supabase.sh -- -d macos
   ```

   Provide any normal `flutter run` flags after `--`. If you prefer to run Flutter directly, continue passing the defines yourself:

   ```bash
   flutter run \
     --dart-define SUPABASE_URL=https://your-project.supabase.co \
     --dart-define SUPABASE_PUBLISHABLE_KEY=your-publishable-key
   ```

   The service role key and database passwords should stay server-side; only the publishable/anon key is injected into the client build.

   Expected table: `videos` with columns `id`, `video_url`, `thumbnail_url`, `title_en`, `title_fr`, `description_en`, `description_fr`, `location_en`, `location_fr`, `creator_name_en`, `creator_name_fr`, `creator_handle`, `likes`, `comments`, `shares`, and `tags` (array of text). Missing credentials just keeps the curated sample feed.

3. Launch the app. Onboarding appears once per runtime and then drops you into the home shell with tabs for Feed, Community, Archive, Music, and Rights.

## Shader notes

- Two custom fragment shaders ship with the app:
  - `shaders/splash_intro.frag` powers the onboarding aura.
  - `shaders/amazigh_wave.frag` powers the music visualiser.
- Ensure you are running on Flutter 3.10+ with Impeller enabled (default on iOS and macOS). For Android, enable `flutter run --enable-impeller` if you hit shader issues.

## Development tips

- The app accesses Supabase only after `SupabaseManager.ensureInitialized` detects `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` (or the legacy `SUPABASE_ANON_KEY`).
- To refresh the video feed manually, tap the refresh icon in the header.
- All assets and shaders are registered in `pubspec.yaml`.
