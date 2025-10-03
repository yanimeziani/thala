import 'package:flutter/material.dart';

/// Displays the Thela logo PNG, scaling it to fit where it's placed.
class ThelaLogo extends StatelessWidget {
  const ThelaLogo({
    super.key,
    this.size,
    this.width,
    this.height,
    this.semanticLabel,
    this.matchTextDirection = false,
    this.fit = BoxFit.contain,
  });

  /// Convenience dimension applied when [width] or [height] are not provided.
  final double? size;

  /// Logo width in logical pixels.
  final double? width;

  /// Logo height in logical pixels.
  final double? height;

  final String? semanticLabel;

  final bool matchTextDirection;

  /// How the logo should be inscribed into the space allocated during layout.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo_transparent.png',
      width: width ?? size,
      height: height ?? size,
      matchTextDirection: matchTextDirection,
      fit: fit,
      semanticLabel: semanticLabel,
    );
  }
}
