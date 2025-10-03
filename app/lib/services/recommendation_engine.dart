import 'dart:math' as math;

import '../data/sample_content_profiles.dart';
import '../models/content_profile.dart';
import '../models/onboarding_answers.dart';
import '../models/video_post.dart';

class RecommendationResult {
  const RecommendationResult({
    required this.post,
    required this.score,
    required this.reasons,
    this.profile,
  });

  final VideoPost post;
  final double score;
  final List<String> reasons;
  final ContentProfile? profile;

  String? get primaryCulturalFamily {
    final families = profile?.culturalFamilies;
    if (families == null || families.isEmpty) {
      return null;
    }
    return families.first;
  }
}

class RecommendationEngine {
  RecommendationEngine({Map<String, ContentProfile>? profiles})
    : _profiles = profiles ?? sampleContentProfiles;

  final Map<String, ContentProfile> _profiles;

  List<RecommendationResult> rank({
    required List<VideoPost> posts,
    OnboardingAnswers? preferences,
  }) {
    final scored = posts.map((post) {
      final profile = _profiles[post.id];
      final reasons = <String>[];
      final base = _popularityScore(post);
      final personalization = _preferenceScore(
        profile: profile,
        preferences: preferences,
        reasons: reasons,
      );
      final guardianBoost = _guardianBoost(profile, reasons);
      final total = base + personalization + guardianBoost;
      return RecommendationResult(
        post: post,
        score: total,
        reasons: reasons,
        profile: profile,
      );
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return _diversify(scored);
  }

  double _popularityScore(VideoPost post) {
    final likes = post.likes.toDouble();
    final shares = post.shares.toDouble();
    final comments = post.comments.toDouble();
    final engagement = likes * 0.6 + shares * 1.1 + comments * 0.4;
    return math.log(1 + engagement);
  }

  double _preferenceScore({
    required ContentProfile? profile,
    required OnboardingAnswers? preferences,
    required List<String> reasons,
  }) {
    if (profile == null || preferences == null) {
      return 0;
    }

    double score = 0;
    final culturalFamily = preferences.culturalFamily;
    if (culturalFamily != null &&
        culturalFamily.isNotEmpty &&
        profile.culturalFamilies.contains(culturalFamily)) {
      score += 3.5;
      reasons.add('Stories from your ${culturalFamily} community');
    }

    final country = preferences.country;
    if (country != null && country.isNotEmpty) {
      final normalizedCountry = country.toLowerCase();
      if (profile.regions.any(
        (region) => region.toLowerCase().contains(normalizedCountry),
      )) {
        score += 2.0;
        reasons.add('Linked to ${country}');
      }
    }

    final isAmazigh = preferences.isAmazigh;
    final interested = preferences.isInterested;

    if (isAmazigh == true && profile.topics.contains('Heritage')) {
      score += 1.2;
      reasons.add('Keeps ancestral heritage in focus');
    }

    if (isAmazigh == false && interested == true) {
      if (profile.topics.contains('Festival') ||
          profile.topics.contains('Community')) {
        score += 0.8;
        reasons.add('Welcomes allies into community celebrations');
      }
      if (profile.topics.contains('Food') ||
          profile.topics.contains('Language')) {
        score += 0.5;
        reasons.add('Accessible cultural doorway for new learners');
      }
    }

    if (preferences.discoverySource != null &&
        preferences.discoverySource!.toLowerCase().contains('music') &&
        profile.topics.contains('Music')) {
      score += 0.6;
      reasons.add('Echoes the musical path you shared');
    }

    return score;
  }

  double _guardianBoost(ContentProfile? profile, List<String> reasons) {
    if (profile == null) {
      return 0;
    }
    if (profile.isGuardianApproved) {
      reasons.add('Blessed by cultural guardians');
      return 0.4;
    }
    if (profile.sacredLevel == 'household_practice') {
      return -0.2;
    }
    return 0;
  }

  List<RecommendationResult> _diversify(List<RecommendationResult> scored) {
    final results = List<RecommendationResult>.from(scored);
    for (var i = 2; i < results.length; i++) {
      final family = results[i].primaryCulturalFamily;
      if (family == null) {
        continue;
      }
      final prev1 = results[i - 1].primaryCulturalFamily;
      final prev2 = results[i - 2].primaryCulturalFamily;
      if (prev1 == family && prev2 == family) {
        final swapIndex = _findNextDifferentFamily(results, family, i + 1);
        if (swapIndex != -1) {
          final temp = results[i];
          results[i] = results[swapIndex];
          results[swapIndex] = temp;
        }
      }
    }
    return results;
  }

  int _findNextDifferentFamily(
    List<RecommendationResult> results,
    String family,
    int start,
  ) {
    for (var index = start; index < results.length; index++) {
      final candidateFamily = results[index].primaryCulturalFamily;
      if (candidateFamily == null || candidateFamily != family) {
        return index;
      }
    }
    return -1;
  }
}
