import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/backend_auth_service.dart';

enum AuthStatus { loading, unauthenticated, authenticated, guest }

class AuthController extends ChangeNotifier {
  AuthController() {
    _init();
  }

  AuthStatus _status = AuthStatus.loading;
  bool _isAuthenticating = false;
  String? _errorMessage;
  UserProfile? _user;
  String? _accessToken;
  String? _refreshToken;

  static const String _accessTokenKey = 'thala_access_token';
  static const String _refreshTokenKey = 'thala_refresh_token';
  static const String _userProfileKey = 'thala_user_profile';

  AuthStatus get status => _status;
  bool get isAuthenticating => _isAuthenticating;
  String? get errorMessage => _errorMessage;
  UserProfile? get user => _user;
  String? get accessToken => _accessToken;
  bool get isGuest => _status == AuthStatus.guest;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final userJson = prefs.getString(_userProfileKey);

      if (accessToken != null && refreshToken != null && userJson != null) {
        _accessToken = accessToken;
        _refreshToken = refreshToken;
        _user = UserProfile.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );

        // Try to verify the token is still valid
        try {
          final user = await BackendAuthService.getCurrentUser(
            accessToken: accessToken,
          );
          _user = user;
          await _saveUserProfile(user);
          _status = AuthStatus.authenticated;
        } catch (e) {
          // Token might be expired, try to refresh
          if (refreshToken != null) {
            try {
              await _refreshAccessToken();
              _status = AuthStatus.authenticated;
            } catch (_) {
              // Refresh failed, need to login again
              await _clearSession();
              _status = AuthStatus.unauthenticated;
            }
          } else {
            await _clearSession();
            _status = AuthStatus.unauthenticated;
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Auth initialization error: $e');
      }
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Please enter an email address.';
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = 'Please enter your password.';
      notifyListeners();
      return false;
    }

    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await BackendAuthService.login(
        email: trimmed,
        password: password,
      );

      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;
      _user = response.user;
      _status = AuthStatus.authenticated;

      await _saveSession(response);
      return true;
    } on BackendAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error. Please try again.';
      if (kDebugMode) {
        debugPrint('Login error: $e');
      }
      return false;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedName = fullName.trim();

    if (trimmedEmail.isEmpty) {
      _errorMessage = 'Please enter an email address.';
      notifyListeners();
      return false;
    }

    if (trimmedName.isEmpty) {
      _errorMessage = 'Please enter your name.';
      notifyListeners();
      return false;
    }

    if (password.isEmpty) {
      _errorMessage = 'Please enter a password.';
      notifyListeners();
      return false;
    }

    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await BackendAuthService.register(
        email: trimmedEmail,
        password: password,
        fullName: trimmedName,
      );

      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;
      _user = response.user;
      _status = AuthStatus.authenticated;

      await _saveSession(response);
      return true;
    } on BackendAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error. Please try again.';
      if (kDebugMode) {
        debugPrint('Registration error: $e');
      }
      return false;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle(String idToken) async {
    _isAuthenticating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await BackendAuthService.loginWithGoogle(
        idToken: idToken,
      );

      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;
      _user = response.user;
      _status = AuthStatus.authenticated;

      await _saveSession(response);
      return true;
    } on BackendAuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Unexpected error. Please try again.';
      if (kDebugMode) {
        debugPrint('Google login error: $e');
      }
      return false;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _clearSession();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await BackendAuthService.refreshToken(
      refreshToken: _refreshToken!,
    );

    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken;
    _user = response.user;

    await _saveSession(response);
  }

  Future<void> _saveSession(AuthTokenResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, response.accessToken);
    await prefs.setString(_refreshTokenKey, response.refreshToken);
    await _saveUserProfile(response.user);
  }

  Future<void> _saveUserProfile(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(user.toJson()));
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userProfileKey);

    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
  }
}
