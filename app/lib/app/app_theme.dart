import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Semantic color palette used across the app for colors that aren't
/// represented directly in the stock Material [ColorScheme].
class ThalaPalette extends ThemeExtension<ThalaPalette> {
  const ThalaPalette({
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.iconPrimary,
    required this.iconMuted,
    required this.surfaceBright,
    required this.surfaceDim,
    required this.surfaceStrong,
    required this.surfaceSubtle,
    required this.border,
    required this.borderStrong,
    required this.overlay,
    required this.inverseSurface,
    required this.inverseText,
    required this.inverseTextSecondary,
    required this.inverseTextMuted,
    required this.inverseIconPrimary,
    required this.inverseIconMuted,
    required this.inverseBorder,
    required this.inverseBorderStrong,
  });

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color iconPrimary;
  final Color iconMuted;
  final Color surfaceBright;
  final Color surfaceDim;
  final Color surfaceStrong;
  final Color surfaceSubtle;
  final Color border;
  final Color borderStrong;
  final Color overlay;
  final Color inverseSurface;
  final Color inverseText;
  final Color inverseTextSecondary;
  final Color inverseTextMuted;
  final Color inverseIconPrimary;
  final Color inverseIconMuted;
  final Color inverseBorder;
  final Color inverseBorderStrong;

  @override
  ThalaPalette copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? iconPrimary,
    Color? iconMuted,
    Color? surfaceBright,
    Color? surfaceDim,
    Color? surfaceStrong,
    Color? surfaceSubtle,
    Color? border,
    Color? borderStrong,
    Color? overlay,
    Color? inverseSurface,
    Color? inverseText,
    Color? inverseTextSecondary,
    Color? inverseTextMuted,
    Color? inverseIconPrimary,
    Color? inverseIconMuted,
    Color? inverseBorder,
    Color? inverseBorderStrong,
  }) {
    return ThalaPalette(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconMuted: iconMuted ?? this.iconMuted,
      surfaceBright: surfaceBright ?? this.surfaceBright,
      surfaceDim: surfaceDim ?? this.surfaceDim,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      overlay: overlay ?? this.overlay,
      inverseSurface: inverseSurface ?? this.inverseSurface,
      inverseText: inverseText ?? this.inverseText,
      inverseTextSecondary:
          inverseTextSecondary ?? this.inverseTextSecondary,
      inverseTextMuted: inverseTextMuted ?? this.inverseTextMuted,
      inverseIconPrimary: inverseIconPrimary ?? this.inverseIconPrimary,
      inverseIconMuted: inverseIconMuted ?? this.inverseIconMuted,
      inverseBorder: inverseBorder ?? this.inverseBorder,
      inverseBorderStrong:
          inverseBorderStrong ?? this.inverseBorderStrong,
    );
  }

  @override
  ThalaPalette lerp(ThemeExtension<ThalaPalette>? other, double t) {
    if (other is! ThalaPalette) {
      return this;
    }
    return ThalaPalette(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t) ?? iconPrimary,
      iconMuted: Color.lerp(iconMuted, other.iconMuted, t) ?? iconMuted,
      surfaceBright:
          Color.lerp(surfaceBright, other.surfaceBright, t) ?? surfaceBright,
      surfaceDim: Color.lerp(surfaceDim, other.surfaceDim, t) ?? surfaceDim,
      surfaceStrong:
          Color.lerp(surfaceStrong, other.surfaceStrong, t) ?? surfaceStrong,
      surfaceSubtle:
          Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      border: Color.lerp(border, other.border, t) ?? border,
      borderStrong:
          Color.lerp(borderStrong, other.borderStrong, t) ?? borderStrong,
      overlay: Color.lerp(overlay, other.overlay, t) ?? overlay,
      inverseSurface:
          Color.lerp(inverseSurface, other.inverseSurface, t) ?? inverseSurface,
      inverseText: Color.lerp(inverseText, other.inverseText, t) ?? inverseText,
      inverseTextSecondary: Color.lerp(
            inverseTextSecondary,
            other.inverseTextSecondary,
            t,
          ) ??
          inverseTextSecondary,
      inverseTextMuted: Color.lerp(
            inverseTextMuted,
            other.inverseTextMuted,
            t,
          ) ??
          inverseTextMuted,
      inverseIconPrimary: Color.lerp(
            inverseIconPrimary,
            other.inverseIconPrimary,
            t,
          ) ??
          inverseIconPrimary,
      inverseIconMuted: Color.lerp(
            inverseIconMuted,
            other.inverseIconMuted,
            t,
          ) ??
          inverseIconMuted,
      inverseBorder: Color.lerp(
            inverseBorder,
            other.inverseBorder,
            t,
          ) ??
          inverseBorder,
      inverseBorderStrong: Color.lerp(
            inverseBorderStrong,
            other.inverseBorderStrong,
            t,
          ) ??
          inverseBorderStrong,
    );
  }
}

ThemeData buildThalaLightTheme() => _buildThalaTheme(Brightness.light);

ThemeData buildThalaDarkTheme() => _buildThalaTheme(Brightness.dark);

ThemeData _buildThalaTheme(Brightness brightness) {
  const primary = Color(0xFF1A4AA8);
  const accent = Color(0xFFEB6A3B);
  const success = Color(0xFF2AC38D);
  const warning = Color(0xFFF4B740);
  const danger = Color(0xFFEA3A3D);

  final bool isDark = brightness == Brightness.dark;

  final background = isDark ? const Color(0xFF050607) : const Color(0xFFF5F6FA);
  final surface = isDark ? const Color(0xFF101217) : Colors.white;
  final surfaceBright = isDark
      ? const Color(0xFF161920)
      : const Color(0xFFF0F2F9);
  final surfaceSubtle = isDark
      ? const Color(0xFF090A0D)
      : const Color(0xFFE8EBF5);
  final onSurface = isDark ? Colors.white : const Color(0xFF1B1E2A);
  final onSurfaceVariant = isDark ? Colors.white70 : const Color(0xFF3E4456);
  final muted = isDark ? Colors.white60 : const Color(0xFF555B6F);
  final iconMuted = isDark ? Colors.white54 : const Color(0xFF71778B);
  final inverseSurface = isDark ? Colors.white : const Color(0xFF1A1D28);
  final inverseText = isDark ? const Color(0xFF121417) : Colors.white;
  final inverseTextSecondary =
      isDark ? const Color(0xFF303545) : Colors.white70;
  final inverseTextMuted =
      isDark ? const Color(0xFF505569) : Colors.white54;
  final inverseIconPrimary =
      isDark ? const Color(0xFF272C3B) : Colors.white;
  final inverseIconMuted =
      isDark ? const Color(0xFF444B5E) : Colors.white70;
  final overlay = isDark
      ? Colors.white.withOpacity(0.08)
      : Colors.black.withOpacity(0.06);
  final border = isDark
      ? Colors.white.withOpacity(0.16)
      : Colors.black.withOpacity(0.08);
  final borderStrong = isDark
      ? Colors.white.withOpacity(0.28)
      : Colors.black.withOpacity(0.16);
  final inverseBorder = isDark
      ? Colors.black.withOpacity(0.08)
      : Colors.white.withOpacity(0.18);
  final inverseBorderStrong = isDark
      ? Colors.black.withOpacity(0.16)
      : Colors.white.withOpacity(0.32);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    primary: primary,
    secondary: accent,
    surface: surface,
    background: background,
    onSurface: onSurface,
    onBackground: onSurface,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    tertiary: success,
    onTertiary: Colors.white,
    error: danger,
    onError: Colors.white,
  );

  final textTheme = GoogleFonts.bricolageGrotesqueTextTheme(
    (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
        .apply(bodyColor: onSurface, displayColor: onSurface),
  ).copyWith(
    headlineSmall: GoogleFonts.bricolageGrotesque(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: onSurface,
    ),
    titleLarge: GoogleFonts.bricolageGrotesque(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
      color: onSurface,
    ),
    bodyLarge: GoogleFonts.bricolageGrotesque(fontSize: 16, height: 1.5),
    bodyMedium: GoogleFonts.bricolageGrotesque(fontSize: 14, height: 1.5),
    labelSmall: GoogleFonts.bricolageGrotesque(letterSpacing: 0.4),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    textTheme: textTheme,
    cardColor: surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    dividerColor: border,
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: Colors.black,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: surface.withOpacity(isDark ? 0.94 : 0.98),
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: accent,
      unselectedItemColor: muted,
      selectedLabelStyle: textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      ),
      unselectedLabelStyle: textTheme.labelSmall?.copyWith(letterSpacing: 0.4),
      showSelectedLabels: true,
      showUnselectedLabels: false,
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: onSurfaceVariant, size: 22),
    tooltipTheme: TooltipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: textTheme.bodySmall?.copyWith(color: inverseText),
      decoration: BoxDecoration(
        color: inverseSurface.withOpacity(isDark ? 0.92 : 0.88),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accent;
        }
        return borderStrong;
      }),
      checkColor: MaterialStateProperty.all(Colors.black),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceBright,
      labelStyle: textTheme.bodySmall?.copyWith(color: onSurface),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      secondarySelectedColor: accent.withOpacity(0.12),
      selectedColor: accent.withOpacity(0.12),
      deleteIconColor: onSurfaceVariant,
    ),
    extensions: [
      ThalaPalette(
        textPrimary: onSurface,
        textSecondary: onSurfaceVariant,
        textMuted: muted,
        iconPrimary: onSurfaceVariant,
        iconMuted: iconMuted,
        surfaceBright: surfaceBright,
        surfaceDim: surface,
        surfaceStrong: isDark
            ? const Color(0xFF1C2027)
            : const Color(0xFFC9CFDF),
        surfaceSubtle: surfaceSubtle,
        border: border,
        borderStrong: borderStrong,
        overlay: overlay,
        inverseSurface: inverseSurface,
        inverseText: inverseText,
        inverseTextSecondary: inverseTextSecondary,
        inverseTextMuted: inverseTextMuted,
        inverseIconPrimary: inverseIconPrimary,
        inverseIconMuted: inverseIconMuted,
        inverseBorder: inverseBorder,
        inverseBorderStrong: inverseBorderStrong,
      ),
    ],
  ).copyWith(
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        side: BorderSide(color: borderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surface,
      filled: true,
      hintStyle: textTheme.bodyMedium?.copyWith(color: muted),
      labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: danger, width: 1.6),
      ),
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: surface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accent,
      circularTrackColor: border,
      linearTrackColor: border,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accent;
        }
        return borderStrong;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return accent.withOpacity(0.4);
        }
        return border.withOpacity(0.5);
      }),
    ),
  );
}

extension ThalaPaletteContext on BuildContext {
  ThalaPalette get thalaPalette {
    final palette = Theme.of(this).extension<ThalaPalette>();
    assert(palette != null, 'ThalaPalette has not been added to the theme');
    return palette!;
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color elevatedOverlay(double opacity) => isDarkMode
      ? Colors.white.withOpacity(opacity)
      : Colors.black.withOpacity(opacity);

  Color inverseOverlay(double opacity) => isDarkMode
      ? Colors.black.withOpacity(opacity)
      : Colors.white.withOpacity(opacity);
}
