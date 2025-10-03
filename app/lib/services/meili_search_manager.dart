import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:meilisearch/meilisearch.dart';

/// Manages the shared Meilisearch client instance used across the app.
///
/// The service reads connection details from compile-time environment values:
///   * `MEILISEARCH_HOST` (falls back to https://search.thala.app)
///   * `MEILISEARCH_SEARCH_KEY` (required to enable the client)
///   * `MEILISEARCH_INDEX` (defaults to `videos`)
class MeiliSearchManager {
  MeiliSearchManager._();

  static bool _initialized = false;
  static final Uri _defaultHost = Uri.parse('https://search.thala.app');
  static const String _defaultIndex = 'videos';

  static MeiliSearchClient? _client;
  static MeiliSearchIndex? _index;

  static MeiliSearchIndex? get index => _index;

  static bool get isConfigured => _initialized && _index != null;

  static Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }

    const rawHost = String.fromEnvironment('MEILISEARCH_HOST');
    const rawApiKey = String.fromEnvironment('MEILISEARCH_SEARCH_KEY');
    const rawIndex = String.fromEnvironment('MEILISEARCH_INDEX');

    final trimmedHost = rawHost.trim();
    final trimmedApiKey = rawApiKey.trim();
    final trimmedIndex = rawIndex.trim();

    if (trimmedApiKey.isEmpty) {
      if (kDebugMode) {
        developer.log(
          'Meilisearch search key not provided. Run with --dart-define MEILISEARCH_SEARCH_KEY to enable search.',
          name: 'MeiliSearchManager',
        );
      }
      _initialized = true;
      return;
    }

    Uri baseUri;
    if (trimmedHost.isEmpty) {
      baseUri = _defaultHost;
    } else {
      final candidate = Uri.tryParse(trimmedHost);
      if (candidate == null || candidate.host.isEmpty) {
        if (kDebugMode) {
          developer.log(
            'MEILISEARCH_HOST "$trimmedHost" is invalid. Falling back to default host ${_defaultHost.toString()}.',
            name: 'MeiliSearchManager',
            level: 900,
          );
        }
        baseUri = _defaultHost;
      } else if (candidate.hasScheme) {
        baseUri = candidate;
      } else {
        baseUri = candidate.replace(scheme: 'https');
      }
    }

    final indexName = trimmedIndex.isNotEmpty ? trimmedIndex : _defaultIndex;

    try {
      _client = MeiliSearchClient(baseUri.toString(), trimmedApiKey);
      _index = _client!.index(indexName);
      if (kDebugMode) {
        developer.log(
          'Meilisearch configured for index "$indexName" at ${baseUri.toString()}',
          name: 'MeiliSearchManager',
        );
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Meilisearch initialization failed. Search will remain disabled.',
          name: 'MeiliSearchManager',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
    } finally {
      _initialized = true;
    }
  }
}
