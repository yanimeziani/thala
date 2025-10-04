import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Generic API client for Thala backend communication
class ApiClient {
  ApiClient._();

  static const String _envApiUrl = String.fromEnvironment('THELA_API_URL');
  static const String _defaultApiUrl = 'https://backend.thala.app';

  static String get baseUrl =>
      _envApiUrl.trim().isNotEmpty ? _envApiUrl.trim() : _defaultApiUrl;

  static String get apiUrl => '$baseUrl/api/v1';

  /// GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$apiUrl$endpoint')
          .replace(queryParameters: queryParameters);

      if (kDebugMode) {
        developer.log('GET $uri', name: 'ApiClient');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        developer.log('GET request failed: $e', name: 'ApiClient', level: 1000);
      }
      rethrow;
    }
  }

  /// POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$apiUrl$endpoint');

      if (kDebugMode) {
        developer.log('POST $uri', name: 'ApiClient');
      }

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        developer.log('POST request failed: $e', name: 'ApiClient', level: 1000);
      }
      rethrow;
    }
  }

  /// PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$apiUrl$endpoint');

      if (kDebugMode) {
        developer.log('PUT $uri', name: 'ApiClient');
      }

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        developer.log('PUT request failed: $e', name: 'ApiClient', level: 1000);
      }
      rethrow;
    }
  }

  /// PATCH request
  static Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$apiUrl$endpoint');

      if (kDebugMode) {
        developer.log('PATCH $uri', name: 'ApiClient');
      }

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        developer.log('PATCH request failed: $e', name: 'ApiClient', level: 1000);
      }
      rethrow;
    }
  }

  /// DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$apiUrl$endpoint');

      if (kDebugMode) {
        developer.log('DELETE $uri', name: 'ApiClient');
      }

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );

      return _handleResponse(response);
    } catch (e) {
      if (kDebugMode) {
        developer.log('DELETE request failed: $e', name: 'ApiClient', level: 1000);
      }
      rethrow;
    }
  }

  /// GET request returning a list
  static Future<List<dynamic>> getList(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('$apiUrl$endpoint')
          .replace(queryParameters: queryParameters);

      if (kDebugMode) {
        developer.log('GET (list) $uri', name: 'ApiClient');
      }

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw ApiException(
          _parseError(response),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      if (kDebugMode) {
        developer.log('GET (list) request failed: $e', name: 'ApiClient', level: 1000);
      }
      throw ApiException('Network error. Please check your connection.');
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ApiException(
        _parseError(response),
        statusCode: response.statusCode,
      );
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

  /// Create headers with authentication token
  static Map<String, String> authHeaders(String accessToken) {
    return {
      'Authorization': 'Bearer $accessToken',
    };
  }
}

/// Exception thrown by ApiClient
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
