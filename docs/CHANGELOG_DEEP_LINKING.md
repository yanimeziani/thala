# Deep Linking & Package Rename - Change Summary

## Changes Made

### 1. Directory Restructure
- ✅ Renamed `landing/` → `web/` to better reflect its purpose

### 2. Package Name Changes
- ✅ **iOS**: Changed from `app.mobile.thala` → `app.thala`
  - Updated `Runner.xcodeproj/project.pbxproj`
  - Updated `Info.plist` CFBundleURLSchemes

- ✅ **Android**: Changed from `com.example.thala` → `app.thala`
  - Updated `android/app/build.gradle.kts` (namespace and applicationId)
  - Moved package from `com/example/thala/` → `app/thala/`
  - Updated `MainActivity.kt` package declaration

### 3. Mobile App Deep Linking

#### Flutter Dependencies
- ✅ Added `app_links: ^6.3.2` to `pubspec.yaml`

#### New Files Created
- ✅ `app/lib/services/deep_link_service.dart` - Deep link handling service
  - Listens for incoming deep links
  - Parses URLs and extracts route information
  - Supports custom schemes and universal links

#### iOS Configuration
- ✅ Updated `ios/Runner/Info.plist`:
  - Changed URL scheme to `app.thala`
  - Added `FlutterDeepLinkingEnabled`

- ✅ Created `ios/Runner/Runner.entitlements`:
  - Added associated domains for `thala.app` and `www.thala.app`

#### Android Configuration
- ✅ Updated `android/app/src/main/AndroidManifest.xml`:
  - Added custom scheme intent filter for `app.thala://`
  - Added App Links intent filter with `autoVerify="true"` for `https://thala.app`
  - Supports both `thala.app` and `www.thala.app`

#### App Integration
- ✅ Updated `app/lib/main.dart`:
  - Initialize `DeepLinkService` on app startup
  - Added deep link listener in `AuthGate`
  - Added `kDebugMode` import for debugging

### 4. Web App Redirect System

#### Redirect Pages Created
- ✅ `web/app/[locale]/events/[id]/page.tsx` - Event redirect page
- ✅ `web/app/[locale]/profile/[id]/page.tsx` - Profile redirect page
- ✅ `web/app/[locale]/video/[id]/page.tsx` - Video redirect page
- ✅ `web/app/[locale]/community/[id]/page.tsx` - Community redirect page

Each redirect page:
- Attempts to open mobile app via custom scheme
- Shows loading UI with spinner
- Provides manual "Open in App" button
- Redirects to App Store/Play Store after 2.5s if app not installed

#### Universal Links Configuration
- ✅ Created `web/public/.well-known/apple-app-site-association`:
  - Configured for iOS Universal Links
  - Supports paths: `/event/*`, `/events/*`, `/profile/*`, `/video/*`, `/community/*`
  - Uses Team ID: `4HYDAPQ96M` (update if different)

- ✅ Created `web/public/.well-known/assetlinks.json`:
  - Configured for Android App Links
  - Package: `app.thala`
  - **Note**: Requires SHA-256 fingerprint to be added

#### Next.js Configuration
- ✅ Updated `web/next.config.ts`:
  - Added custom headers for `.well-known` files
  - Ensures correct `Content-Type: application/json`

### 5. Documentation
- ✅ Created `DEEP_LINKING.md` - Comprehensive deep linking setup guide
- ✅ Created `CHANGELOG_DEEP_LINKING.md` - This file

## Deep Link URL Schemes

### Custom Scheme (works immediately)
- Events: `app.thala://event/{id}`
- Profiles: `app.thala://profile/{id}`
- Videos: `app.thala://video/{id}`
- Communities: `app.thala://community/{id}`

### Universal/App Links (requires server setup)
- Events: `https://thala.app/event/{id}`
- Profiles: `https://thala.app/profile/{id}`
- Videos: `https://thala.app/video/{id}`
- Communities: `https://thala.app/community/{id}`

## Before Deployment

### iOS
- [ ] Add `Runner.entitlements` to Xcode project target
- [ ] Enable "Associated Domains" capability in Xcode
- [ ] Verify Apple Team ID in `apple-app-site-association`
- [ ] Update App Store link in redirect pages

### Android
- [ ] Generate SHA-256 fingerprint: `cd app/android && ./gradlew signingReport`
- [ ] Update `assetlinks.json` with fingerprint
- [ ] Update Play Store link in redirect pages

### Web
- [ ] Deploy to `thala.app` domain
- [ ] Verify `.well-known` files are accessible via HTTPS
- [ ] Test universal links on physical devices

## Testing Commands

### iOS
```bash
# Simulator (custom scheme only)
xcrun simctl openurl booted "app.thala://event/test-123"

# Physical device - send via Messages/Notes
https://thala.app/event/test-123
```

### Android
```bash
# Test custom scheme
adb shell am start -a android.intent.action.VIEW -d "app.thala://event/test-123"

# Test App Links
adb shell am start -a android.intent.action.VIEW -d "https://thala.app/event/test-123"

# Verify app link configuration
adb shell pm get-app-links app.thala
```

## Files Modified

### Mobile App
- `app/pubspec.yaml`
- `app/lib/main.dart`
- `app/lib/services/deep_link_service.dart` (new)
- `app/ios/Runner/Info.plist`
- `app/ios/Runner/Runner.entitlements` (new)
- `app/ios/Runner.xcodeproj/project.pbxproj`
- `app/android/app/build.gradle.kts`
- `app/android/app/src/main/AndroidManifest.xml`
- `app/android/app/src/main/kotlin/app/thala/MainActivity.kt`

### Web App
- `web/next.config.ts`
- `web/app/[locale]/events/[id]/page.tsx` (new)
- `web/app/[locale]/profile/[id]/page.tsx` (new)
- `web/app/[locale]/video/[id]/page.tsx` (new)
- `web/app/[locale]/community/[id]/page.tsx` (new)
- `web/public/.well-known/apple-app-site-association` (new)
- `web/public/.well-known/assetlinks.json` (new)

## Breaking Changes

⚠️ **Package name changed**: Existing users will need to reinstall the app, as the package name changed from `app.mobile.thala` to `app.thala`.

## Next Steps

1. Complete iOS Xcode project configuration
2. Generate and add Android SHA-256 fingerprint
3. Update App Store and Play Store links
4. Deploy web app to production
5. Test universal links on physical devices
6. Implement deep link navigation in app (currently just logs)
