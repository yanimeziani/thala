import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for authenticating with the Thela FastAPI backend
class BackendAuthService {
  BackendAuthService._();

  static const String _envApiUrl = String.fromEnvironment('THELA_API_URL');
  static const String _defaultApiUrl = 'https://backend.thala.app';

  static String get baseUrl =>
      _envApiUrl.trim().isNotEmpty ? _envApiUrl.trim() : _defaultApiUrl;

  static String get apiUrl => '$baseUrl/api/v1';

  /// Register a new user with email and password
  static Future<AuthTokenResponse> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/auth/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'full_name': fullName,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokenResponse.fromJson(data);
      } else {
        final error = _parseError(response);
        throw BackendAuthException(error);
      }
    } catch (e) {
      if (e is BackendAuthException) {
        rethrow;
      }
      if (kDebugMode) {
        developer.log(
          'Registration failed: $e',
          name: 'BackendAuthService',
          level: 1000,
        );
      }
      throw BackendAuthException('Network error. Please check your connection.');
    }
  }

  /// Login with email and password
  static Future<AuthTokenResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokenResponse.fromJson(data);
      } else {
        final error = _parseError(response);
        throw BackendAuthException(error);
      }
    } catch (e) {
      if (e is BackendAuthException) {
        rethrow;
      }
      if (kDebugMode) {
        developer.log(
          'Login failed: $e',
          name: 'BackendAuthService',
          level: 1000,
        );
      }
      throw BackendAuthException('Network error. Please check your connection.');
    }
  }

  /// Login with Google ID token
  static Future<AuthTokenResponse> loginWithGoogle({
    required String idToken,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/auth/google');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokenResponse.fromJson(data);
      } else {
        final error = _parseError(response);
        throw BackendAuthException(error);
      }
    } catch (e) {
      if (e is BackendAuthException) {
        rethrow;
      }
      if (kDebugMode) {
        developer.log(
          'Google login failed: $e',
          name: 'BackendAuthService',
          level: 1000,
        );
      }
      throw BackendAuthException('Network error. Please check your connection.');
    }
  }

  /// Refresh access token using refresh token
  static Future<AuthTokenResponse> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/auth/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AuthTokenResponse.fromJson(data);
      } else {
        final error = _parseError(response);
        throw BackendAuthException(error);
      }
    } catch (e) {
      if (e is BackendAuthException) {
        rethrow;
      }
      if (kDebugMode) {
        developer.log(
          'Token refresh failed: $e',
          name: 'BackendAuthService',
          level: 1000,
        );
      }
      throw BackendAuthException('Network error. Please check your connection.');
    }
  }

  /// Get current user profile
  static Future<UserProfile> getCurrentUser({
    required String accessToken,
  }) async {
    try {
      final url = Uri.parse('$apiUrl/auth/me');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return UserProfile.fromJson(data);
      } else {
        final error = _parseError(response);
        throw BackendAuthException(error);
      }
    } catch (e) {
      if (e is BackendAuthException) {
        rethrow;
      }
      if (kDebugMode) {
        developer.log(
          'Get current user failed: $e',
          name: 'BackendAuthService',
          level: 1000,
        );
      }
      throw BackendAuthException('Network error. Please check your connection.');
    }
  }

  static String _parseError(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['detail'] as String? ?? 'Unknown error occurred';
    } catch (_) {
      return 'Server error (${response.statusCode})';
    }
  }
}

/// Exception thrown by BackendAuthService
class BackendAuthException implements Exception {
  BackendAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Authentication token response from backend
class AuthTokenResponse {
  AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserProfile user;

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int? ?? 3600,
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// User profile from backend
class UserProfile {
  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.picture,
    this.locale,
    this.isActive = true,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? picture;
  final String? locale;
  final bool isActive;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      picture: json['picture'] as String?,
      locale: json['locale'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'picture': picture,
      'locale': locale,
      'is_active': isActive,
    };
  }
}
