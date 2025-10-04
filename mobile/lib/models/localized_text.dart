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

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      en: json['en'] as String? ?? '',
      fr: json['fr'] as String? ?? json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'fr': fr,
    };
  }
}
