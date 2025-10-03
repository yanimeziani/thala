# Deep Linking Setup for Thala

This document explains the deep linking system that allows web links to open the Thala mobile app.

## Overview

The system supports:
- **Custom URL schemes**: `app.thala://`
- **Universal Links (iOS)**: `https://thala.app/*`
- **App Links (Android)**: `https://thala.app/*`

## Supported Link Types

| Type | Web URL | App Deep Link |
|------|---------|---------------|
| Event | `https://thala.app/event/{id}` | `app.thala://event/{id}` |
| Profile | `https://thala.app/profile/{id}` | `app.thala://profile/{id}` |
| Video | `https://thala.app/video/{id}` | `app.thala://video/{id}` |
| Community | `https://thala.app/community/{id}` | `app.thala://community/{id}` |

## Package Name

The app package name has been changed to:
- **iOS Bundle ID**: `app.thala`
- **Android Package**: `app.thala`

## Mobile App Configuration

### Flutter Setup

1. **Dependencies** (`app/pubspec.yaml`):
   ```yaml
   dependencies:
     app_links: ^6.3.2
   ```

2. **Deep Link Service** (`app/lib/services/deep_link_service.dart`):
   - Handles incoming deep links
   - Parses URLs and routes to appropriate screens
   - Initialized in `main.dart`

### iOS Configuration

1. **Info.plist** (`app/ios/Runner/Info.plist`):
   - Custom URL scheme: `app.thala`
   - FlutterDeepLinkingEnabled: `true`

2. **Entitlements** (`app/ios/Runner/Runner.entitlements`):
   - Associated domains: `applinks:thala.app`, `applinks:www.thala.app`

3. **Xcode Project**:
   - Add the `Runner.entitlements` file to the Xcode project
   - Enable "Associated Domains" capability in Signing & Capabilities
   - Add domains: `applinks:thala.app` and `applinks:www.thala.app`

### Android Configuration

1. **AndroidManifest.xml** (`app/android/app/src/main/AndroidManifest.xml`):
   - Custom scheme intent filter for `app.thala://`
   - App Links intent filter with `autoVerify="true"` for `https://thala.app`

2. **Package Structure**:
   - Moved from `com.example.thala` to `app.thala`
   - Updated `MainActivity.kt` package declaration

## Web App Configuration (Next.js)

### Redirect Pages

Created redirect pages for each deep link type in `web/app/[locale]/`:
- `events/[id]/page.tsx`
- `profile/[id]/page.tsx`
- `video/[id]/page.tsx`
- `community/[id]/page.tsx`

These pages:
1. Attempt to open the mobile app using custom scheme
2. Wait 2.5 seconds
3. Redirect to App Store (iOS) or Play Store (Android) if app doesn't open
4. Show a loading UI with manual "Open in App" button

### Universal Links Configuration

#### Apple App Site Association
Location: `web/public/.well-known/apple-app-site-association`

```json
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "4HYDAPQ96M.app.thala",
        "paths": ["/event/*", "/events/*", "/profile/*", "/video/*", "/community/*"]
      }
    ]
  }
}
```

**Note**: Replace `4HYDAPQ96M` with your actual Apple Team ID.

#### Android Asset Links
Location: `web/public/.well-known/assetlinks.json`

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "app.thala",
      "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
    }
  }
]
```

**To get your SHA256 fingerprint**:
```bash
cd app/android
./gradlew signingReport
```

Copy the SHA-256 fingerprint and update `assetlinks.json`.

### Next.js Headers
Updated `web/next.config.ts` to serve `.well-known` files with correct content type.

## Deployment Checklist

### iOS
- [ ] Add `Runner.entitlements` to Xcode project
- [ ] Enable Associated Domains capability
- [ ] Add domains: `applinks:thala.app` and `applinks:www.thala.app`
- [ ] Verify Team ID in `apple-app-site-association` matches your Apple Developer Team ID
- [ ] Deploy web app and verify `https://thala.app/.well-known/apple-app-site-association` is accessible
- [ ] Test universal links on physical iOS device (doesn't work in simulator)

### Android
- [ ] Get SHA-256 fingerprint from signing report
- [ ] Update `assetlinks.json` with your fingerprint
- [ ] Deploy web app and verify `https://thala.app/.well-known/assetlinks.json` is accessible
- [ ] Test App Links using: `adb shell am start -a android.intent.action.VIEW -d "https://thala.app/event/test"`

### Web
- [ ] Update App Store links in redirect pages (replace placeholder IDs)
- [ ] Update Play Store links in redirect pages
- [ ] Deploy Next.js app to production
- [ ] Verify `.well-known` files are accessible via HTTPS

## Testing

### iOS Universal Links
```bash
# On macOS, test with:
xcrun simctl openurl booted "https://thala.app/event/test-event-id"

# On physical device, send link via Messages/Notes and tap it
```

### Android App Links
```bash
# Test with adb:
adb shell am start -a android.intent.action.VIEW -d "https://thala.app/event/test-event-id"

# Verify app link setup:
adb shell pm get-app-links app.thala
```

### Custom Schemes
```bash
# iOS:
xcrun simctl openurl booted "app.thala://event/test-event-id"

# Android:
adb shell am start -a android.intent.action.VIEW -d "app.thala://event/test-event-id"
```

## How It Works

1. **User clicks a link**: `https://thala.app/event/123`
2. **Mobile OS checks**:
   - iOS: Looks for `apple-app-site-association` on `thala.app`
   - Android: Looks for `assetlinks.json` on `thala.app`
3. **If app is installed**: Opens app directly with deep link
4. **If app is not installed**: Opens web page
5. **Web page**:
   - Tries custom scheme: `app.thala://event/123`
   - Waits 2.5 seconds
   - Redirects to App Store/Play Store if app doesn't open

## Troubleshooting

### iOS Universal Links Not Working
- Verify `apple-app-site-association` is accessible at `https://thala.app/.well-known/apple-app-site-association`
- Check content-type is `application/json`
- Ensure Team ID matches your Apple Developer account
- Test on physical device (simulator doesn't support universal links fully)
- Reset OS link cache: Delete app, restart device, reinstall

### Android App Links Not Working
- Verify `assetlinks.json` is accessible at `https://thala.app/.well-known/assetlinks.json`
- Check SHA-256 fingerprint matches your keystore
- Use `adb shell pm get-app-links app.thala` to verify status
- Clear defaults: Settings → Apps → Thala → Set as default → Clear defaults

### Custom Schemes Not Working
- Check AndroidManifest.xml has intent filter for `app.thala` scheme
- Check Info.plist has `CFBundleURLTypes` with `app.thala` scheme
- Run `flutter pub get` after adding `app_links` package

## App Store Links

Update these in the redirect pages once your app is published:
- **iOS**: `https://apps.apple.com/app/thala/id[YOUR_APP_ID]`
- **Android**: `https://play.google.com/store/apps/details?id=app.thala`
