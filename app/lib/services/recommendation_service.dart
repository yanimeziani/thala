import '../data/feed_repository.dart';
import '../models/onboarding_answers.dart';
import '../models/video_post.dart';
import 'preference_store.dart';
import 'recommendation_engine.dart';

class RecommendationService {
  RecommendationService({
    FeedRepository? feedRepository,
    PreferenceStore? preferenceStore,
    RecommendationEngine? engine,
  }) : _feedRepository = feedRepository ?? const FeedRepository(),
       _preferenceStore = preferenceStore ?? PreferenceStore(),
       _engine = engine ?? RecommendationEngine();

  final FeedRepository _feedRepository;
  final PreferenceStore _preferenceStore;
  final RecommendationEngine _engine;

  Map<String, List<String>> _lastExplanations = <String, List<String>>{};

  Future<List<VideoPost>> fetchRecommendedFeed() async {
    final posts = await _feedRepository.fetchFeed();
    final preferences = await _preferenceStore.loadOnboardingAnswers();
    final ranked = _engine.rank(posts: posts, preferences: preferences);

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
}
