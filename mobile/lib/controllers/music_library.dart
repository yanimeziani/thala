import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../data/music_repository.dart';
import '../models/music_track.dart';

class MusicLibrary extends ChangeNotifier {
  MusicLibrary({MusicRepository? repository, List<MusicTrack> fallback = const []})
      : _repository = repository ?? MusicRepository(),
        _tracks = fallback {
    _load();
  }

  final MusicRepository _repository;
  List<MusicTrack> _tracks;
  bool _isLoading = false;
  String? _error;

  List<MusicTrack> get tracks => List<MusicTrack>.unmodifiable(_tracks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRemoteEnabled => _repository.isRemoteEnabled;

  Future<void> refresh() => _load(force: true);

  Future<void> _load({bool force = false}) async {
    if (!force && _tracks.isNotEmpty && _repository.isRemoteEnabled) {
      return;
    }

    if (!_repository.isRemoteEnabled) {
      _error = 'Backend not configured';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final remoteTracks = await _repository.fetchTracks();
      if (remoteTracks.isNotEmpty) {
        _tracks = remoteTracks;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        developer.log(
          'Failed to refresh music library',
          name: 'MusicLibrary',
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
      }
      _error = 'Unable to load music tracks.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  MusicTrack? trackById(String? id) {
    if (id == null) {
      return null;
    }
    try {
      return _tracks.firstWhere((track) => track.id == id);
    } catch (_) {
      return null;
    }
  }
}
