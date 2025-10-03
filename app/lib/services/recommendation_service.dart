import 'package:flutter/foundation.dart';

import '../data/content_profile_repository.dart';
import '../data/feed_repository.dart';
import '../data/sample_content_profiles.dart';
import '../models/content_profile.dart';
import '../models/onboarding_answers.dart';
import '../models/video_post.dart';
import 'preference_store.dart';
import 'recommendation_engine.dart';

class RecommendationService {
  RecommendationService({
    FeedRepository? feedRepository,
    PreferenceStore? preferenceStore,
    ContentProfileRepository? profileRepository,
  })  : _feedRepository = feedRepository ?? const FeedRepository(),
        _preferenceStore = preferenceStore ?? PreferenceStore(),
        _profileRepository =
            profileRepository ?? ContentProfileRepository();

  final FeedRepository _feedRepository;
  final PreferenceStore _preferenceStore;
  final ContentProfileRepository _profileRepository;
  Map<String, ContentProfile>? _cachedProfiles;

  Map<String, List<String>> _lastExplanations = <String, List<String>>{};

  Future<List<VideoPost>> fetchRecommendedFeed() async {
    final posts = await _feedRepository.fetchFeed();
    final profiles = await _ensureProfiles();
    final engine = RecommendationEngine(profiles: profiles);
    final preferences = await _preferenceStore.loadOnboardingAnswers();
    final ranked = engine.rank(posts: posts, preferences: preferences);

    _lastExplanations = <String, List<String>>{
      for (final result in ranked)
        result.post.id: List<String>.from(result.reasons),
    };

    return ranked.map((result) => result.post).toList(growable: false);
  }

  List<String>? explanationsFor(String postId) => _lastExplanations[postId];

  Future<void> saveOnboardingAnswers(OnboardingAnswers answers) async {
    await _preferenceStore.saveOnboardingAnswers(answers);
  }

  Future<OnboardingAnswers?> loadOnboardingAnswers() {
    return _preferenceStore.loadOnboardingAnswers();
  }

  Future<Map<String, ContentProfile>> _ensureProfiles() async {
    if (_cachedProfiles != null && _cachedProfiles!.isNotEmpty) {
      return _cachedProfiles!;
    }

    if (!_profileRepository.isRemoteEnabled) {
      _cachedProfiles = sampleContentProfiles;
      return _cachedProfiles!;
    }

    try {
      final result = await _profileRepository.fetchProfiles();
      if (result.isNotEmpty) {
        _cachedProfiles = result;
      } else {
        _cachedProfiles = sampleContentProfiles;
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to fetch content profiles: $error\n$stackTrace');
      _cachedProfiles = sampleContentProfiles;
    }
    return _cachedProfiles!;
  }
}
