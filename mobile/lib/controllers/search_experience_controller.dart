import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:meilisearch/meilisearch.dart' hide SearchResult;

import '../data/search_repository.dart';
import '../models/search_hit.dart';

class SearchExperienceController extends ChangeNotifier {
  SearchExperienceController({SearchRepository? repository})
      : _repository = repository ?? const SearchRepository();

  final SearchRepository _repository;

  Timer? _debounce;
  bool _isLoading = false;
  String? _errorMessage;
  String _query = '';
  List<SearchHit> _results = <SearchHit>[];

  bool get isRemoteEnabled => _repository.isRemoteEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  List<SearchHit> get results => List<SearchHit>.unmodifiable(_results);

  void updateQuery(String value) {
    final trimmed = value.trim();
    _query = trimmed;
    _errorMessage = null;

    _debounce?.cancel();

    if (trimmed.isEmpty) {
      _results = <SearchHit>[];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 280), () {
      unawaited(_executeSearch(trimmed));
    });
    notifyListeners();
  }

  Future<void> submitQuery(String value) async {
    final trimmed = value.trim();
    _debounce?.cancel();
    _query = trimmed;
    _errorMessage = null;

    if (trimmed.isEmpty) {
      _results = <SearchHit>[];
      _isLoading = false;
      notifyListeners();
      return;
    }

    await _executeSearch(trimmed);
  }

  Future<void> retry() => submitQuery(_query);

  Future<void> _executeSearch(String query) async {
    if (!_repository.isRemoteEnabled) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final results = await _repository.search(query);
      _results = results;
      _errorMessage = null;
    } on MeiliSearchApiException catch (error, stackTrace) {
      _errorMessage = 'Search is temporarily unavailable. Please retry shortly.';
      if (kDebugMode) {
        developer.log(
          'Meilisearch API error',
          name: 'SearchExperienceController',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
    } catch (error, stackTrace) {
      _errorMessage = 'Search failed unexpectedly. Please retry.';
      if (kDebugMode) {
        developer.log(
          'Unexpected search error',
          name: 'SearchExperienceController',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
