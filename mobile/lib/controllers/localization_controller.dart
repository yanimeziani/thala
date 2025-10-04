import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, french, arabic }

/// Handles the active locale and notifies listeners when the user toggles language.
class LocalizationController extends ChangeNotifier {
  LocalizationController({Locale? initialLocale})
    : _locale = _sanitize(initialLocale ?? const Locale('en'));

  static const _preferenceKey = 'thala.preferredLanguage';

  static const supportedLocales = <Locale>[Locale('en'), Locale('fr'), Locale('ar')];

  Locale _locale;

  Locale get locale => _locale;

  AppLanguage get language {
    final code = _locale.languageCode.toLowerCase();
    if (code == 'fr') return AppLanguage.french;
    if (code == 'ar') return AppLanguage.arabic;
    return AppLanguage.english;
  }

  Future<void> loadPreferredLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedCode = prefs.getString(_preferenceKey);
      if (storedCode == null) {
        return;
      }
      final storedLocale = _sanitize(Locale(storedCode));
      if (_locale == storedLocale) {
        return;
      }
      _locale = storedLocale;
      notifyListeners();
    } catch (_) {
      // Ignore preference read failures and fall back to detected locale.
    }
  }

  void setLanguage(AppLanguage language) {
    final Locale target;
    switch (language) {
      case AppLanguage.french:
        target = const Locale('fr');
        break;
      case AppLanguage.arabic:
        target = const Locale('ar');
        break;
      case AppLanguage.english:
      default:
        target = const Locale('en');
        break;
    }
    if (_locale == target) return;
    _locale = target;
    notifyListeners();
    unawaited(_persistLocale(target));
  }

  void toggleLanguage() {
    setLanguage(
      language == AppLanguage.english
          ? AppLanguage.french
          : language == AppLanguage.french
              ? AppLanguage.arabic
              : AppLanguage.english,
    );
  }

  Future<void> _persistLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_preferenceKey, locale.languageCode.toLowerCase());
    } catch (_) {
      // Ignore preference write failures so the UI can continue updating.
    }
  }

  static Locale _sanitize(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (code == 'fr') {
      return const Locale('fr');
    }
    if (code == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }
}
