# Dark Mode Adaptive App Icons

The Thala app now supports adaptive icons that change appearance based on the device's dark mode setting.

## iOS Icon Requirements

iOS uses the Asset Catalog system with dark mode variants. The icons are configured in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`.

### Required Icon Sizes (Light Mode - Already Exist)
These files should already exist:
- `Icon-App-20x20@2x.png` (40x40px)
- `Icon-App-20x20@3x.png` (60x60px)
- `Icon-App-29x29@1x.png` (29x29px)
- `Icon-App-29x29@2x.png` (58x58px)
- `Icon-App-29x29@3x.png` (87x87px)
- `Icon-App-40x40@2x.png` (80x80px)
- `Icon-App-40x40@3x.png` (120x120px)
- `Icon-App-60x60@2x.png` (120x120px)
- `Icon-App-60x60@3x.png` (180x180px)
- `Icon-App-20x20@1x.png` (20x20px - iPad)
- `Icon-App-40x40@1x.png` (40x40px - iPad)
- `Icon-App-76x76@1x.png` (76x76px - iPad)
- `Icon-App-76x76@2x.png` (152x152px - iPad)
- `Icon-App-83.5x83.5@2x.png` (167x167px - iPad Pro)
- `Icon-App-1024x1024@1x.png` (1024x1024px - App Store)

### Required Icon Sizes (Dark Mode - TO BE CREATED)
Create these dark mode variants with `-dark` suffix:
- `Icon-App-20x20@2x-dark.png` (40x40px)
- `Icon-App-20x20@3x-dark.png` (60x60px)
- `Icon-App-29x29@1x-dark.png` (29x29px)
- `Icon-App-29x29@2x-dark.png` (58x58px)
- `Icon-App-29x29@3x-dark.png` (87x87px)
- `Icon-App-40x40@2x-dark.png` (80x80px)
- `Icon-App-40x40@3x-dark.png` (120x120px)
- `Icon-App-60x60@2x-dark.png` (120x120px)
- `Icon-App-60x60@3x-dark.png` (180x180px)
- `Icon-App-20x20@1x-dark.png` (20x20px - iPad)
- `Icon-App-40x40@1x-dark.png` (40x40px - iPad)
- `Icon-App-76x76@1x-dark.png` (76x76px - iPad)
- `Icon-App-76x76@2x-dark.png` (152x152px - iPad)
- `Icon-App-83.5x83.5@2x-dark.png` (167x167px - iPad Pro)

**Note:** The 1024x1024 App Store icon does not need a dark variant.

## Android Icon Requirements

Android uses resource qualifiers for night mode. Icons go in different density folders.

### Light Mode Icons (Already Exist)
Located in `android/app/src/main/res/mipmap-*/`:
- `mipmap-mdpi/ic_launcher.png` (48x48px)
- `mipmap-hdpi/ic_launcher.png` (72x72px)
- `mipmap-xhdpi/ic_launcher.png` (96x96px)
- `mipmap-xxhdpi/ic_launcher.png` (144x144px)
- `mipmap-xxxhdpi/ic_launcher.png` (192x192px)

### Dark Mode Icons (TO BE CREATED)
Located in `android/app/src/main/res/mipmap-night-*/`:
- `mipmap-night-mdpi/ic_launcher.png` (48x48px)
- `mipmap-night-hdpi/ic_launcher.png` (72x72px)
- `mipmap-night-xhdpi/ic_launcher.png` (96x96px)
- `mipmap-night-xxhdpi/ic_launcher.png` (144x144px)
- `mipmap-night-xxxhdpi/ic_launcher.png` (192x192px)

## Design Guidelines

### Current Light Mode Icon
The current icon appears to be the Thala logo with transparent background.

### Dark Mode Icon Recommendations
For optimal dark mode appearance:

1. **Contrast Adjustment**: Ensure the icon has sufficient contrast against dark backgrounds
2. **Color Adaptation**: Consider using lighter/brighter tones of the brand colors
3. **Transparency**: Maintain transparency if the current design uses it
4. **Brand Consistency**: Keep the core design elements but adjust for dark mode visibility

### Suggested Approach
- **Light Mode**: Current orange/coral Tifinagh symbol (ⵀ) design
- **Dark Mode**: Same design but with:
  - Brighter/lighter orange accent (#ff9569 instead of #f06a3e)
  - Potentially add subtle glow or outline for better visibility
  - Consider subtle background gradient if needed for visibility

## Testing

After adding the dark mode icons:

### iOS Testing
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Build and run on simulator
3. Toggle dark mode: Settings → Developer → Dark Appearance
4. Check home screen icon appearance

### Android Testing
1. Build and install: `flutter build apk && flutter install`
2. Toggle dark mode: Settings → Display → Dark theme
3. Check launcher icon appearance

## Implementation Status

- ✅ iOS: `Contents.json` configured for dark mode variants
- ✅ Android: Night mode mipmap directories created
- ⏳ Icons: Dark mode variants need to be designed and added
- ⏳ Testing: Pending icon creation

## Notes

- iOS dark mode icons are supported on iOS 13+ (all target devices)
- Android night mode icons are supported on Android 10+ (API 29+)
- The configuration is complete; only the actual icon assets need to be created
- Once icons are added, they will automatically adapt to system appearance
