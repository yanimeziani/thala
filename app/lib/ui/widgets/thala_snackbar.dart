import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

SnackBar buildThalaSnackBar(
  BuildContext context, {
  required IconData icon,
  Duration duration = const Duration(milliseconds: 2600),
  Color? iconColor,
  Color? badgeColor,
  String? semanticsLabel,
  SnackBarAction? action,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final bool isCupertino =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  final double badgeSize = isCupertino ? 72 : 60;
  final double cornerRadius = isCupertino ? 30 : 24;

  final Color resolvedBadgeColor =
      badgeColor ??
      colorScheme.surfaceBright.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.34 : 0.68,
      );

  Widget badge = Container(
    height: badgeSize,
    width: badgeSize,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(cornerRadius),
      border: Border.all(
        color: isCupertino
            ? Colors.white.withValues(alpha: 0.24)
            : colorScheme.primary.withValues(alpha: 0.18),
      ),
      boxShadow: [
        if (isCupertino)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 18),
          )
        else
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: resolvedBadgeColor,
              gradient: isCupertino
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.32),
                        resolvedBadgeColor,
                      ],
                    )
                  : null,
            ),
          ),
          if (isCupertino)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: const SizedBox.expand(),
            ),
          Center(
            child: Icon(
              icon,
              size: isCupertino ? 30 : 26,
              color:
                  iconColor ??
                  (isCupertino ? Colors.white : colorScheme.primary),
            ),
          ),
        ],
      ),
    ),
  );

  if (isCupertino) {
    badge = LiquidGlass(
      glassContainsChild: false,
      shape: LiquidRoundedSuperellipse(
        borderRadius: Radius.circular(cornerRadius),
      ),
      settings: const LiquidGlassSettings(
        thickness: 9,
        blur: 18,
        glassColor: Color(0x28FFFFFF),
        ambientStrength: 0.38,
        lightIntensity: 1.18,
        blend: 22,
        saturation: 1.05,
        lightness: 1.06,
      ),
      child: badge,
    );
  }

  Widget body = SizedBox.square(dimension: badgeSize, child: badge);

  if (semanticsLabel != null && semanticsLabel.isNotEmpty) {
    body = Semantics(label: semanticsLabel, child: body);
  } else {
    body = ExcludeSemantics(child: body);
  }

  return SnackBar(
    duration: duration,
    action: action,
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.zero,
    margin: EdgeInsets.only(
      left: isCupertino ? 120 : 32,
      right: isCupertino ? 120 : 32,
      bottom: isCupertino ? 72 : 24,
    ),
    content: Align(alignment: Alignment.center, child: body),
  );
}
