import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';

import '../data/feed_actions_repository.dart';
import '../l10n/app_translations.dart';
import '../models/video_post.dart';
import '../services/recommendation_service.dart';
import '../services/story_publishing_service.dart';

class FeedController extends ChangeNotifier {
  FeedController({
    FeedActionsRepository? actionsRepository,
    RecommendationService? recommendationService,
    StoryPublishingService? storyPublishingService,
  }) : _actionsRepository = actionsRepository ?? FeedActionsRepository(),
       _recommendationService =
           recommendationService ?? RecommendationService(),
       _storyPublisher = storyPublishingService ?? StoryPublishingService() {
    _loadInitial();
  }

  final FeedActionsRepository _actionsRepository;
  final RecommendationService _recommendationService;
  final StoryPublishingService _storyPublisher;

  final List<VideoPost> _localPosts = <VideoPost>[];
  List<VideoPost> _remotePosts = <VideoPost>[];
  bool _isLoading = true;
  bool _isFeedVisible = true;
  String? _error;
  final Set<String> _likedPostIds = <String>{};
  final Set<String> _followedCreatorHandles = <String>{};
  final Set<String> _pendingUpdates = <String>{};
  String? _actionErrorMessage;

  List<VideoPost> get posts => <VideoPost>[..._localPosts, ..._remotePosts];
  bool get isLoading => _isLoading;
  bool get isFeedVisible => _isFeedVisible;
  String? get error => _error;
  String? get actionErrorMessage => _actionErrorMessage;

  bool get hasLocalPosts => _localPosts.isNotEmpty;
  bool get isRemoteEnabled => _actionsRepository.isRemoteEnabled;

  List<String>? explanationFor(VideoPost post) {
    return _recommendationService.explanationsFor(post.id);
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await _load();
  }

  void setFeedVisibility(bool isVisible) {
    if (_isFeedVisible == isVisible) {
      return;
    }
    _isFeedVisible = isVisible;
    notifyListeners();
  }

  void addLocalPost(VideoPost post) {
    _localPosts.insert(0, post);
    notifyListeners();
    _attemptPublish(post);
  }

  bool isLiked(VideoPost post) => _likedPostIds.contains(post.id);

  bool isFollowing(VideoPost post) =>
      _followedCreatorHandles.contains(post.creatorHandle);

  bool isBusy(String postId) => _pendingUpdates.contains(postId);

  bool isUpdatePending(String key) => _pendingUpdates.contains(key);

  void clearActionError() {
    if (_actionErrorMessage != null) {
      _actionErrorMessage = null;
      notifyListeners();
    }
  }

  Future<void> toggleLike(VideoPost post) async {
    if (_pendingUpdates.contains(post.id)) {
      return;
    }

    final shouldLike = !_likedPostIds.contains(post.id);
    final delta = shouldLike ? 1 : -1;
    final nextLikes = (post.likes + delta).clamp(0, 1 << 31);
    final updated = post.copyWith(likes: nextLikes);

    _pendingUpdates.add(post.id);
    _applyPostUpdate(updated);
    if (shouldLike) {
      _likedPostIds.add(post.id);
    } else {
      _likedPostIds.remove(post.id);
    }
    notifyListeners();

    try {
      await _actionsRepository.updateCounters(post.id, likes: nextLikes);
    } catch (error) {
      _actionErrorMessage =
          'Unable to update like right now. Please try again.';
      if (shouldLike) {
        _likedPostIds.remove(post.id);
      } else {
        _likedPostIds.add(post.id);
      }
      _applyPostUpdate(post);
      notifyListeners();
    } finally {
      if (_pendingUpdates.remove(post.id)) {
        notifyListeners();
      }
    }
  }

  Future<void> toggleFollow({
    required VideoPost post,
    required String userId,
  }) async {
    if (!_actionsRepository.isRemoteEnabled) {
      _actionErrorMessage = 'Connect Supabase to manage follows.';
      notifyListeners();
      return;
    }

    if (_pendingUpdates.contains('${post.id}-follow')) {
      return;
    }

    final isFollowingNow = _followedCreatorHandles.contains(post.creatorHandle);
    final nextState = !isFollowingNow;

    if (nextState) {
      _followedCreatorHandles.add(post.creatorHandle);
    } else {
      _followedCreatorHandles.remove(post.creatorHandle);
    }
    _pendingUpdates.add('${post.id}-follow');
    notifyListeners();

    try {
      await _actionsRepository.setFollow(
        creatorHandle: post.creatorHandle,
        userId: userId,
        follow: nextState,
      );
    } catch (error) {
      _actionErrorMessage = 'Unable to update follow preference just yet.';
      if (nextState) {
        _followedCreatorHandles.remove(post.creatorHandle);
      } else {
        _followedCreatorHandles.add(post.creatorHandle);
      }
      notifyListeners();
    } finally {
      if (_pendingUpdates.remove('${post.id}-follow')) {
        notifyListeners();
      }
    }
  }

  Future<bool> submitComment({
    required VideoPost post,
    required String userId,
    required String comment,
  }) async {
    if (!_actionsRepository.isRemoteEnabled) {
      _actionErrorMessage = 'Connect Supabase to enable comments.';
      notifyListeners();
      return false;
    }

    if (_pendingUpdates.contains('${post.id}-comment')) {
      return false;
    }

    final trimmed = comment.trim();
    if (trimmed.isEmpty) {
      _actionErrorMessage = 'Comment cannot be empty.';
      notifyListeners();
      return false;
    }

    _pendingUpdates.add('${post.id}-comment');

    final updated = post.copyWith(comments: post.comments + 1);
    _applyPostUpdate(updated);
    notifyListeners();

    try {
      await _actionsRepository.recordComment(
        videoId: post.id,
        userId: userId,
        content: trimmed,
      );
      await _actionsRepository.updateCounters(
        post.id,
        comments: updated.comments,
      );
      return true;
    } catch (error) {
      _actionErrorMessage = 'Failed to send comment. Please try again.';
      _applyPostUpdate(post);
      notifyListeners();
      return false;
    } finally {
      if (_pendingUpdates.remove('${post.id}-comment')) {
        notifyListeners();
      }
    }
  }

  Future<bool> recordShare({
    required VideoPost post,
    required String? userId,
  }) async {
    if (_pendingUpdates.contains('${post.id}-share')) {
      return false;
    }

    final updated = post.copyWith(shares: post.shares + 1);
    _pendingUpdates.add('${post.id}-share');
    _applyPostUpdate(updated);
    notifyListeners();

    try {
      if (userId != null && userId.isNotEmpty) {
        await _actionsRepository.recordShare(videoId: post.id, userId: userId);
      }
      await _actionsRepository.updateCounters(post.id, shares: updated.shares);
      return true;
    } catch (error) {
      _actionErrorMessage = 'Unable to record share at the moment.';
      _applyPostUpdate(post);
      notifyListeners();
      return false;
    } finally {
      if (_pendingUpdates.remove('${post.id}-share')) {
        notifyListeners();
      }
    }
  }

  Future<void> _loadInitial() async {
    await _load();
  }

  Future<void> _load() async {
    try {
      _error = null;
      final results = await _recommendationService.fetchRecommendedFeed();
      _remotePosts = List<VideoPost>.from(results);
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyPostUpdate(VideoPost updated) {
    final localIndex = _localPosts.indexWhere(
      (element) => element.id == updated.id,
    );
    if (localIndex != -1) {
      _localPosts[localIndex] = updated;
    }

    final remoteIndex = _remotePosts.indexWhere(
      (element) => element.id == updated.id,
    );
    if (remoteIndex != -1) {
      final next = List<VideoPost>.from(_remotePosts);
      next[remoteIndex] = updated;
      _remotePosts = next;
    }
  }

  Future<void> _attemptPublish(VideoPost post) async {
    if (!_storyPublisher.isRemoteEnabled || !post.isLocalDraft) {
      return;
    }
    final publishKey = '${post.id}-publish';
    if (!_pendingUpdates.add(publishKey)) {
      return;
    }
    notifyListeners();

    try {
      final published = await _storyPublisher.publish(post);
      if (published == null) {
        return;
      }

      _localPosts.removeWhere((element) => element.id == post.id);

      final filteredRemote = _remotePosts
          .where((element) => element.id != post.id)
          .toList();
      _remotePosts = <VideoPost>[published, ...filteredRemote];
      notifyListeners();
    } catch (error) {
      _actionErrorMessage ??= AppTranslations.fromLocale(
        const Locale('en'),
        AppText.feedPublishDeferred,
      );
      notifyListeners();
    } finally {
      if (_pendingUpdates.remove(publishKey)) {
        notifyListeners();
      }
    }
  }
}
