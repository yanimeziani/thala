import 'package:flutter/foundation.dart';

import '../data/events_repository.dart';
import '../models/cultural_event.dart';

class EventsController extends ChangeNotifier {
  EventsController({required this.repository});

  final EventsRepository repository;
  List<CulturalEvent> _events = const <CulturalEvent>[];
  bool _isLoading = true;
  String? _errorMessage;

  List<CulturalEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadEvents() async {
    if (!repository.isRemoteEnabled) {
      _isLoading = false;
      _errorMessage = 'Backend is not configured. Events will appear once connected.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final remote = await repository.fetchUpcomingEvents();
      _events = remote;
      _isLoading = false;
      if (remote.isEmpty) {
        _errorMessage = 'No events published yet.';
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load cultural events: $error\n$stackTrace');
      _events = const <CulturalEvent>[];
      _isLoading = false;
      _errorMessage = 'Unable to reach backend. Events will return once the connection recovers.';
    }
    notifyListeners();
  }

  Future<bool> toggleInterest(String eventId) async {
    try {
      await repository.toggleInterest(eventId);

      // Update the local event state
      final index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        final event = _events[index];
        final wasInterested = event.isUserInterested;
        _events = List.from(_events);
        _events[index] = event.copyWith(
          isUserInterested: !wasInterested,
          interestedCount: wasInterested
              ? event.interestedCount - 1
              : event.interestedCount + 1,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Failed to toggle interest: $e');
      return false;
    }
  }
}
