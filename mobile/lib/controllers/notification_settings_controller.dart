import 'dart:async';

import 'package:flutter/material.dart';

import '../models/notification_settings.dart';
import '../services/preference_store.dart';

class NotificationSettingsController extends ChangeNotifier {
  NotificationSettingsController({required PreferenceStore preferenceStore})
    : _preferenceStore = preferenceStore {
    unawaited(_load());
  }

  final PreferenceStore _preferenceStore;

  NotificationSettings _settings = const NotificationSettings();
  bool _isLoaded = false;

  NotificationSettings get settings => _settings;
  bool get isLoaded => _isLoaded;

  Future<void> toggleStoryAlerts(bool value) async {
    _update(_settings.copyWith(storyAlerts: value));
  }

  Future<void> toggleCommunityHighlights(bool value) async {
    _update(_settings.copyWith(communityHighlights: value));
  }

  Future<void> toggleProductUpdates(bool value) async {
    _update(_settings.copyWith(productUpdates: value));
  }

  Future<void> _load() async {
    final stored = await _preferenceStore.loadNotificationSettings();
    _settings = stored;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _update(NotificationSettings next) async {
    if (_settings == next) {
      return;
    }
    _settings = next;
    notifyListeners();
    try {
      await _preferenceStore.saveNotificationSettings(next);
    } catch (_) {
      // Ignore persistence failures and keep in-memory state updated.
    }
  }
}
