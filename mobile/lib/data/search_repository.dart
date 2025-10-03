import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:meilisearch/meilisearch.dart' hide SearchResult;

import '../models/search_hit.dart';
import '../services/meili_search_manager.dart';

class SearchRepository {
  const SearchRepository();

  bool get isRemoteEnabled => MeiliSearchManager.isConfigured;

  Future<List<SearchHit>> search(String query, {int limit = 20}) async {
    final index = MeiliSearchManager.index;
    if (index == null || query.trim().isEmpty) {
      return const <SearchHit>[];
    }

    try {
      final searchResponse = await index.search(
        query,
        SearchQuery(limit: limit),
      );
      final hits = searchResponse.hits;
      if (hits == null || hits.isEmpty) {
        return const <SearchHit>[];
      }
      return hits
          .whereType<Map<String, dynamic>>()
          .map(SearchHit.fromHit)
          .toList(growable: false);
    } on MeiliSearchApiException catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Meilisearch query failed',
          name: 'SearchRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      rethrow;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Unexpected search failure',
          name: 'SearchRepository',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      rethrow;
    }
  }
}
