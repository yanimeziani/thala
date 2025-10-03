import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import '../../app/app_theme.dart';

bool _supportsLiquidGlass() {
  if (kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
}

class ThalaGlassSurface extends StatelessWidget {
  const ThalaGlassSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.cornerRadius = 28,
    this.backgroundOpacity,
    this.backgroundColor,
    this.borderColor,
    this.shadows,
    this.enableBorder = true,
    this.enableLiquid,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double cornerRadius;
  final double? backgroundOpacity;
  final Color? backgroundColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final bool enableBorder;
  final bool? enableLiquid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(cornerRadius);
    final bool useLiquidGlass =
        (enableLiquid ?? true) && _supportsLiquidGlass();

    final double resolvedOpacity = backgroundOpacity ?? (isDark ? 0.18 : 0.68);
    final double surfaceAlpha = resolvedOpacity.clamp(0.0, 1.0);
    final Color surfaceColor = (backgroundColor ?? palette.surfaceBright)
        .withValues(alpha: surfaceAlpha);
    final Color resolvedBorder = (borderColor ?? palette.borderStrong)
        .withValues(alpha: isDark ? 0.45 : 0.28);

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: borderRadius,
        border: enableBorder ? Border.all(color: resolvedBorder) : null,
        boxShadow: shadows,
      ),
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (useLiquidGlass) {
      surface = LiquidGlass(
        glassContainsChild: false,
        shape: LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(cornerRadius),
        ),
        settings: const LiquidGlassSettings(
          thickness: 9,
          blur: 16,
          glassColor: Color(0x24FFFFFF),
          ambientStrength: 0.26,
          lightIntensity: 1.08,
          blend: 18,
          saturation: 1.02,
          lightness: 1.01,
        ),
        child: surface,
      );
    } else {
      surface = ClipRRect(borderRadius: borderRadius, child: surface);
    }

    if (margin != null) {
      surface = Padding(padding: margin!, child: surface);
    }

    return surface;
  }
}

class ThalaPageBackground extends StatelessWidget {
  const ThalaPageBackground({
    super.key,
    required this.child,
    this.padding,
    this.colors,
    this.begin,
    this.end,
    this.stops,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final List<Color>? colors;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;
  final List<double>? stops;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = theme.brightness == Brightness.dark;

    final List<Color> resolvedColors =
        colors ??
        (isDark
            ? <Color>[
                const Color(0xFF050607),
                palette.surfaceDim,
                theme.scaffoldBackgroundColor,
              ]
            : <Color>[palette.surfaceBright, theme.scaffoldBackgroundColor]);

    final decoration = BoxDecoration(
      gradient: LinearGradient(
        colors: resolvedColors,
        begin: begin ?? Alignment.topCenter,
        end: end ?? Alignment.bottomCenter,
        stops: stops,
      ),
    );

    final Widget content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    return DecoratedBox(decoration: decoration, child: content);
  }
}
