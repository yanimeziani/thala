import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_manager.dart';

enum AuthStatus { loading, unauthenticated, authenticated, unavailable, guest }

class AuthController extends ChangeNotifier {
  AuthController({SupabaseClient? client})
    : _client = client ?? SupabaseManager.client {
    _init();
  }

  final SupabaseClient? _client;
  StreamSubscription<AuthState>? _authSubscription;

  AuthStatus _status = AuthStatus.loading;
  Session? _session;
  bool _isAuthenticating = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  Session? get session => _session;
  bool get isAuthenticating => _isAuthenticating;
  String? get errorMessage => _errorMessage;
  bool get isGuest => _status == AuthStatus.guest;

  void _init() {
    final client = _client;
    if (client == null) {
      _status = AuthStatus.guest;
      notifyListeners();
      return;
    }

    _session = client.auth.currentSession;
    _status = _session == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;

    _authSubscription = client.auth.onAuthStateChange.listen(
      (data) => _handleAuthStateChange(data.event, data.session),
      onError: (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('Auth listener error: $error');
        }
      },
    );

    notifyListeners();
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    final client = _client;
    if (client == null) {
      _errorMessage =
          'Supabase is not configured. Provide credentials to enable sign-in.';
      notifyListeners();
      return false;
    }

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
      await client.auth.signInWithPassword(email: trimmed, password: password);
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (error) {
      _errorMessage = 'Unexpected error. Please try again.';
      return false;
    } finally {
      _isAuthenticating = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) {
      return;
    }
    await client.auth.signOut();
    _setSession(null);
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _handleAuthStateChange(AuthChangeEvent event, Session? session) {
    switch (event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
      case AuthChangeEvent.initialSession:
        _errorMessage = null;
        _setSession(session);
        break;
      case AuthChangeEvent.signedOut:
        _setSession(null);
        break;
      default:
        if (session != null) {
          _setSession(session);
        }
    }
  }

  void _setSession(Session? session) {
    _session = session;
    final nextStatus = session == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    if (_status != nextStatus) {
      _status = nextStatus;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
