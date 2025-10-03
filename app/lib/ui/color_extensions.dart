import 'package:flutter/material.dart';

/// Adds a `withValues` helper to [Color] so existing call sites can adjust
/// channel values using a similar API to Flutter master.
extension ColorWithValues on Color {
  /// Returns a copy of this color with selected channels overridden.
  ///
  /// The optional parameters accept values in the range 0.0–1.0. If a value
  /// greater than 1.0 is provided, it is assumed to be in 0–255 and converted
  /// accordingly. All inputs are clamped to the supported range.
  Color withValues({
    double? alpha,
    double? red,
    double? green,
    double? blue,
  }) {
    double resolveChannel(double? input, int existing) {
      if (input == null) {
        return existing / 255.0;
      }
      if (input.isNaN) {
        return existing / 255.0;
      }
      if (input <= 1.0 && input >= 0.0) {
        return input;
      }
      return (input / 255.0).clamp(0.0, 1.0);
    }

    final double resolvedAlpha = resolveChannel(alpha, this.alpha);
    final double resolvedRed = resolveChannel(red, this.red);
    final double resolvedGreen = resolveChannel(green, this.green);
    final double resolvedBlue = resolveChannel(blue, this.blue);

    return Color.fromRGBO(
      (resolvedRed * 255).round(),
      (resolvedGreen * 255).round(),
      (resolvedBlue * 255).round(),
      resolvedAlpha,
    );
  }
}
