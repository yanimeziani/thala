import 'package:flutter_test/flutter_test.dart';

import 'package:thala/models/content_profile.dart';
import 'package:thala/models/localized_text.dart';
import 'package:thala/models/onboarding_answers.dart';
import 'package:thala/models/video_post.dart';
import 'package:thala/services/recommendation_engine.dart';

void main() {
  group('RecommendationEngine', () {
    VideoPost buildPost({
      required String id,
      int likes = 0,
      int shares = 0,
      int comments = 0,
    }) {
      return VideoPost(
        id: id,
        videoUrl: 'https://example.com/$id.mp4',
        title: const LocalizedText(en: 'title', fr: 'titre'),
        description: const LocalizedText(en: 'desc', fr: 'desc'),
        location: const LocalizedText(en: 'Algeria', fr: 'Algérie'),
        creatorName: const LocalizedText(en: 'Creator', fr: 'Créateur'),
        creatorHandle: '@$id',
        likes: likes,
        comments: comments,
        shares: shares,
      );
    }

    test('elevates stories matching onboarding signals', () {
      final engine = RecommendationEngine(
        profiles: {
          'kabyle-story': const ContentProfile(
            contentId: 'kabyle-story',
            culturalFamilies: ['Kabyle'],
            regions: ['Kabylie', 'Algeria'],
            topics: ['Heritage'],
            isGuardianApproved: true,
            sacredLevel: 'guardian_reviewed',
          ),
          'general-story': const ContentProfile(
            contentId: 'general-story',
            culturalFamilies: ['Atlas'],
            regions: ['Morocco'],
            topics: ['Festival'],
          ),
        },
      );

      final posts = [
        buildPost(id: 'kabyle-story', likes: 80, shares: 5, comments: 3),
        buildPost(id: 'general-story', likes: 300, shares: 20, comments: 15),
      ];

      final answers = OnboardingAnswers(
        culturalFamily: 'Kabyle',
        country: 'Algeria',
        isAmazigh: true,
      );

      final results = engine.rank(posts: posts, preferences: answers);

      expect(results.first.post.id, 'kabyle-story');
      expect(
        results.first.reasons,
        contains('Stories from your Kabyle community'),
      );
      expect(
        results.first.reasons,
        contains('Linked to Algeria'),
      );
    });

    test('diversifies results to avoid three of the same family in a row', () {
      final engine = RecommendationEngine(
        profiles: {
          'kab-1': const ContentProfile(
            contentId: 'kab-1',
            culturalFamilies: ['Kabyle'],
            regions: ['Kabylie'],
          ),
          'kab-2': const ContentProfile(
            contentId: 'kab-2',
            culturalFamilies: ['Kabyle'],
            regions: ['Kabylie'],
          ),
          'kab-3': const ContentProfile(
            contentId: 'kab-3',
            culturalFamilies: ['Kabyle'],
            regions: ['Kabylie'],
          ),
          'rif-1': const ContentProfile(
            contentId: 'rif-1',
            culturalFamilies: ['Rifian'],
            regions: ['Rif'],
          ),
        },
      );

      final posts = [
        buildPost(id: 'kab-1', likes: 400, shares: 40, comments: 20),
        buildPost(id: 'kab-2', likes: 380, shares: 35, comments: 18),
        buildPost(id: 'kab-3', likes: 360, shares: 32, comments: 15),
        buildPost(id: 'rif-1', likes: 100, shares: 8, comments: 5),
      ];

      final results = engine.rank(posts: posts, preferences: null);

      // Without diversification logic, the first three entries would all be
      // Kabyle content. Ensure the third slot was swapped for the Rifian story.
      expect(results[0].post.id, 'kab-1');
      expect(results[1].post.id, 'kab-2');
      expect(results[2].post.id, 'rif-1');

      final families = results
          .map((result) => result.primaryCulturalFamily)
          .toList(growable: false);

      for (var i = 2; i < families.length; i++) {
        final current = families[i];
        final previous = families[i - 1];
        final beforePrevious = families[i - 2];
        expect(
          current == previous && current == beforePrevious,
          isFalse,
          reason: 'Found three consecutive stories from $current',
        );
      }
    });

    test('applies guardian blessing bonus and reason', () {
      final engine = RecommendationEngine(
        profiles: {
          'guardian-story': const ContentProfile(
            contentId: 'guardian-story',
            culturalFamilies: ['Tuareg'],
            regions: ['Hoggar'],
            topics: ['Music'],
            isGuardianApproved: true,
            sacredLevel: 'guardian_reviewed',
          ),
          'public-story': const ContentProfile(
            contentId: 'public-story',
            culturalFamilies: ['Tuareg'],
            regions: ['Hoggar'],
            topics: ['Music'],
            isGuardianApproved: false,
            sacredLevel: 'public_celebration',
          ),
        },
      );

      final posts = [
        buildPost(id: 'guardian-story', likes: 150, shares: 10, comments: 6),
        buildPost(id: 'public-story', likes: 160, shares: 9, comments: 5),
      ];

      final results = engine.rank(posts: posts, preferences: null);

      expect(results.first.post.id, 'guardian-story');
      expect(
        results.first.reasons,
        contains('Blessed by cultural guardians'),
      );
    });
  });
}
