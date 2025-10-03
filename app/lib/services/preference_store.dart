import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_settings.dart';
import '../models/onboarding_answers.dart';
import '../models/user_profile.dart';

class PreferenceStore {
  PreferenceStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static const _onboardingKey = 'thela.onboarding_answers';
  static const _notificationSettingsKey = 'thela.notification_settings';
  static const _profileKeyPrefix = 'thela.profile.';

  SharedPreferences? _preferences;
  OnboardingAnswers? _cachedOnboarding;
  NotificationSettings? _cachedNotificationSettings;
  final Map<String, UserProfile> _profileCache = <String, UserProfile>{};

  Future<void> saveOnboardingAnswers(OnboardingAnswers answers) async {
    final prefs = await _ensurePreferences();
    _cachedOnboarding = answers.copyWith();
    await prefs.setString(_onboardingKey, json.encode(answers.toJson()));
  }

  Future<OnboardingAnswers?> loadOnboardingAnswers() async {
    if (_cachedOnboarding != null) {
      return _cachedOnboarding;
    }

    final prefs = await _ensurePreferences();
    final stored = prefs.getString(_onboardingKey);
    if (stored == null || stored.isEmpty) {
      return null;
    }

    try {
      final decoded = json.decode(stored);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      _cachedOnboarding = OnboardingAnswers.fromJson(decoded);
      return _cachedOnboarding;
    } on FormatException {
      return null;
    }
  }

  Future<void> clearOnboardingAnswers() async {
    final prefs = await _ensurePreferences();
    _cachedOnboarding = null;
    await prefs.remove(_onboardingKey);
  }

  Future<NotificationSettings> loadNotificationSettings() async {
    final cached = _cachedNotificationSettings;
    if (cached != null) {
      return cached;
    }

    final prefs = await _ensurePreferences();
    final stored = prefs.getString(_notificationSettingsKey);
    if (stored == null || stored.isEmpty) {
      const defaults = NotificationSettings();
      _cachedNotificationSettings = defaults;
      return defaults;
    }

    try {
      final decoded = json.decode(stored);
      if (decoded is! Map<String, dynamic>) {
        const defaults = NotificationSettings();
        _cachedNotificationSettings = defaults;
        return defaults;
      }
      final settings = NotificationSettings.fromJson(decoded);
      _cachedNotificationSettings = settings;
      return settings;
    } on FormatException {
      const defaults = NotificationSettings();
      _cachedNotificationSettings = defaults;
      return defaults;
    }
  }

  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    final prefs = await _ensurePreferences();
    _cachedNotificationSettings = settings;
    await prefs.setString(
      _notificationSettingsKey,
      json.encode(settings.toJson()),
    );
  }

  Future<UserProfile?> loadUserProfile(String userId) async {
    if (userId.isEmpty) {
      return null;
    }

    final cached = _profileCache[userId];
    if (cached != null) {
      return cached;
    }

    final prefs = await _ensurePreferences();
    final stored = prefs.getString('$_profileKeyPrefix$userId');
    if (stored == null || stored.isEmpty) {
      return null;
    }

    try {
      final decoded = json.decode(stored);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final profile = UserProfile.fromJson(decoded);
      _profileCache[userId] = profile;
      return profile;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    if (profile.userId.isEmpty) {
      return;
    }

    final prefs = await _ensurePreferences();
    _profileCache[profile.userId] = profile;
    await prefs.setString(
      '$_profileKeyPrefix${profile.userId}',
      json.encode(profile.toJson()),
    );
  }

  Future<void> clearUserProfile(String userId) async {
    if (userId.isEmpty) {
      return;
    }

    _profileCache.remove(userId);
    final prefs = await _ensurePreferences();
    await prefs.remove('$_profileKeyPrefix$userId');
  }

  Future<SharedPreferences> _ensurePreferences() async {
    final prefs = _preferences;
    if (prefs != null) {
      return prefs;
    }
    final instance = await SharedPreferences.getInstance();
    _preferences = instance;
    return instance;
  }
}
