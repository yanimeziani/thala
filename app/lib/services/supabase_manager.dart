import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralizes Supabase bootstrapping so the rest of the app can just depend on
/// [SupabaseManager.client].
class SupabaseManager {
  SupabaseManager._();

  static bool _initialized = false;

  static SupabaseClient? get client {
    if (!_initialized) {
      return null;
    }
    return Supabase.instance.client;
  }

  static bool get isConfigured => _initialized;

  /// Initializes Supabase using compile-time environment values.
  ///
  /// Provide `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` (or the legacy
  /// `SUPABASE_ANON_KEY`) via `--dart-define`.
  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    const rawUrl = String.fromEnvironment('SUPABASE_URL');
    const rawPublishableKey = String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
    );
    const rawAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    final supabaseUrl = rawUrl.trim();
    final publishableKey = rawPublishableKey.trim();
    final anonKey = rawAnonKey.trim();
    final supabaseKey = publishableKey.isNotEmpty ? publishableKey : anonKey;

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      if (kDebugMode) {
        developer.log(
          'Supabase credentials not provided. Run with --dart-define SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY (or SUPABASE_ANON_KEY) to enable remote data.',
          name: 'SupabaseManager',
        );
      }
      return;
    }

    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      if (kDebugMode) {
        developer.log(
          'Supabase URL "$supabaseUrl" is invalid. Expected an http or https URL. Falling back to local sample data.',
          name: 'SupabaseManager',
          level: 900,
        );
      }
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.implicit,
          autoRefreshToken: true,
        ),
      );
      _initialized = true;
      if (kDebugMode) {
        final keyType = publishableKey.isNotEmpty
            ? 'publishable key'
            : 'anon key';
        developer.log(
          'Supabase initialized successfully using $keyType.',
          name: 'SupabaseManager',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Supabase initialization failed. Falling back to local sample data.',
          name: 'SupabaseManager',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
    }
  }
}
