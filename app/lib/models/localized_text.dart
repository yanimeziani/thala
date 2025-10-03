import 'package:flutter/material.dart';

/// Simple value object that stores the English and French copy for a string.
class LocalizedText {
  const LocalizedText({required this.en, required this.fr});

  final String en;
  final String fr;

  /// Resolves the string against the provided [locale].
  String resolve(Locale locale) {
    return locale.languageCode.toLowerCase() == 'fr' ? fr : en;
  }
}
