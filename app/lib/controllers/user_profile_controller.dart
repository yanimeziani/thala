import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/user_profile_repository.dart';
import '../models/user_profile.dart';
import '../services/preference_store.dart';
import 'auth_controller.dart';

class UserProfileController extends ChangeNotifier {
  UserProfileController({
    required AuthController authController,
    required PreferenceStore preferenceStore,
    UserProfileRepository? repository,
  })  : _authController = authController,
        _preferenceStore = preferenceStore,
        _repository = repository ?? UserProfileRepository() {
    _authListener = _handleAuthChanged;
    _authController.addListener(_authListener!);
    unawaited(_initialize());
  }

  final AuthController _authController;
  final PreferenceStore _preferenceStore;
  final UserProfileRepository _repository;

  VoidCallback? _authListener;

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get isAuthenticated =>
      _authController.status == AuthStatus.authenticated;

  Future<void> reload() async {
    await _loadProfile();
  }

  Future<bool> save(UserProfile profile) async {
    final session = _authController.session;
    final user = session?.user;
    if (user == null) {
      _error = 'You need to be signed in to update your profile.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      UserProfile next = profile.copyWith(
        userId: user.id,
        email: user.email ?? profile.email,
      );
      try {
        final remote = await _repository.saveProfile(next);
        if (remote != null) {
          next = remote;
        }
      } on AuthException catch (error) {
        _error = error.message;
        _isSaving = false;
        notifyListeners();
        return false;
      }

      _profile = next;
      await _preferenceStore.saveUserProfile(next);
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (error) {
      _error = 'We could not update your profile right now. Please retry.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _initialize() async {
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final session = _authController.session;
    final user = session?.user;
    if (user == null) {
      _profile = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final cached = await _preferenceStore.loadUserProfile(user.id);
    var profile = UserProfile.fromUser(user, fallback: cached);

    final remote = await _repository.refreshProfile(fallback: profile);
    profile = remote ?? profile;

    _profile = profile;
    await _preferenceStore.saveUserProfile(profile);

    _isLoading = false;
    notifyListeners();
  }

  void _handleAuthChanged() {
    final session = _authController.session;
    final user = session?.user;
    final currentId = _profile?.userId;
    final needsReload =
        user == null ? currentId != null : currentId != user.id;
    if (user == null && currentId != null) {
      unawaited(_preferenceStore.clearUserProfile(currentId));
    }
    if (needsReload) {
      unawaited(_loadProfile());
    }
  }

  @override
  void dispose() {
    final listener = _authListener;
    if (listener != null) {
      _authController.removeListener(listener);
    }
    super.dispose();
  }
}
