import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/feed_controller.dart';
import '../../controllers/messages_controller.dart';
import '../../l10n/app_translations.dart';
import '../../models/video_post.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../../ui/widgets/thala_snackbar.dart';
import '../messages/message_thread_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.post});

  final VideoPost post;

  static Future<T?> push<T>(BuildContext context, {required VideoPost post}) {
    final feed = context.read<FeedController>();
    final messages = _maybeReadMessages(context);
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (routeContext) => MultiProvider(
          providers: [
            ChangeNotifierProvider<FeedController>.value(value: feed),
            if (messages != null)
              ChangeNotifierProvider<MessagesController>.value(value: messages),
          ],
          child: UserProfilePage(post: post),
        ),
      ),
    );
  }

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isStartingDm = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final feed = context.watch<FeedController>();
    final String creatorHandle = widget.post.creatorHandle;

    final List<VideoPost> creatorPosts = feed.posts
        .where((candidate) => candidate.creatorHandle == creatorHandle)
        .toList();
    if (creatorPosts.every((candidate) => candidate.id != widget.post.id)) {
      creatorPosts.insert(0, widget.post);
    }

    final List<VideoPost> heroPosts = creatorPosts.isEmpty
        ? <VideoPost>[widget.post]
        : creatorPosts;
    final VideoPost featuredPost = heroPosts.first;

    final String displayName = featuredPost.creatorName.resolve(locale);
    final String handleLabel = '@$creatorHandle';
    final String heroTitle = displayName.isEmpty ? handleLabel : displayName;
    final String location = featuredPost.location.resolve(locale);
    final String? bio = _cleanDescription(
      featuredPost.description.resolve(locale),
    );
    final List<String> tags = _collectTags(heroPosts).toList(growable: false);

    final int storyCount = heroPosts.length;
    final int totalLikes = heroPosts.fold(0, (sum, post) => sum + post.likes);
    final int totalShares = heroPosts.fold(0, (sum, post) => sum + post.shares);

    final String storiesStatLabel =
        AppTranslations.of(context, AppText.profileStoriesCountLabel);
    final String appreciationsStatLabel =
        AppTranslations.of(context, AppText.profileAppreciationsCountLabel);
    final String sharesStatLabel =
        AppTranslations.of(context, AppText.profileSharesCountLabel);

    final List<_ProfileStat> stats = <_ProfileStat>[
      _ProfileStat(label: storiesStatLabel, value: _formatNumber(storyCount)),
      _ProfileStat(
        label: appreciationsStatLabel,
        value: _formatNumber(totalLikes),
      ),
      _ProfileStat(label: sharesStatLabel, value: _formatNumber(totalShares)),
    ];

    final List<VideoPost> likedPosts = creatorPosts
        .where((post) => feed.isLiked(post))
        .toList(growable: false);

    final List<VideoPost> mediaPosts = creatorPosts
        .where(
          (post) =>
              post.galleryUrls.isNotEmpty ||
              (post.imageUrl != null && post.imageUrl!.trim().isNotEmpty) ||
              post.textSlides.isNotEmpty,
        )
        .toList(growable: false);

    final MessagesController? messagesController = _maybeReadMessages(context);
    final bool messagingEnabled =
        messagesController != null && messagesController.isRemoteEnabled;

    final String messageLabel =
        AppTranslations.of(context, AppText.profileMessageAction);
    final String storiesTabLabel =
        AppTranslations.of(context, AppText.profileStoriesTab);
    final String likedTabLabel =
        AppTranslations.of(context, AppText.profileLikedTab);
    final String mediaTabLabel =
        AppTranslations.of(context, AppText.profileMediaTab);
    final String storiesEmptyTitle =
        AppTranslations.of(context, AppText.profileStoriesEmptyTitle);
    final String storiesEmptyMessage =
        AppTranslations.of(context, AppText.profileStoriesEmptyMessage);
    final String likedEmptyTitle =
        AppTranslations.of(context, AppText.profileLikedEmptyTitle);
    final String likedEmptyMessage =
        AppTranslations.of(context, AppText.profileLikedEmptyMessage);
    final String mediaEmptyTitle =
        AppTranslations.of(context, AppText.profileMediaEmptyTitle);
    final String mediaEmptyMessage =
        AppTranslations.of(context, AppText.profileMediaEmptyMessage);

    final Widget actions = _ProfileActionsRow(
      followButton: _FollowButton(post: widget.post),
      messageLabel: messageLabel,
      onMessage: messagingEnabled ? () => _startDirectMessage(heroTitle) : null,
      isMessaging: _isStartingDm,
      messagingEnabled: messagingEnabled,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          top: false,
          bottom: true,
          child: Hero(
            tag: 'profile-${widget.post.creatorHandle}',
            child: Stack(
              children: [
                // Fixed profile header
                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      _ProfileHero(
                        featuredPost: featuredPost,
                        displayName: heroTitle,
                        handle: handleLabel,
                        location: location,
                        bio: bio,
                        tags: tags,
                        stats: stats,
                        actionRow: actions,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                    ],
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: palette.iconPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                // Sliding bottom sheet with tabs
                DraggableScrollableSheet(
                  initialChildSize: 0.35,
                  minChildSize: 0.15,
                  maxChildSize: 0.9,
                  snap: true,
                  snapSizes: const [0.15, 0.35, 0.9],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: palette.textMuted.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          // Tabs
                          _ProfileTabs(
                            storiesLabel: storiesTabLabel,
                            likedLabel: likedTabLabel,
                            mediaLabel: mediaTabLabel,
                          ),
                          // Tab content
                          Expanded(
                            child: TabBarView(
                              children: [
                                _ProfileStoriesList(
                                  posts: creatorPosts,
                                  locale: locale,
                                  emptyTitle: storiesEmptyTitle,
                                  emptyMessage: storiesEmptyMessage,
                                  emptyIcon: Icons.local_movies_outlined,
                                  scrollController: scrollController,
                                ),
                                _ProfileStoriesList(
                                  posts: likedPosts,
                                  locale: locale,
                                  emptyTitle: likedEmptyTitle,
                                  emptyMessage: likedEmptyMessage,
                                  emptyIcon: Icons.favorite_border,
                                  scrollController: scrollController,
                                ),
                                _ProfileMediaGrid(
                                  posts: mediaPosts,
                                  locale: locale,
                                  emptyTitle: mediaEmptyTitle,
                                  emptyMessage: mediaEmptyMessage,
                                  scrollController: scrollController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startDirectMessage(String displayName) async {
    final MessagesController? messages = _maybeReadMessages(context);
    if (messages == null || !messages.isRemoteEnabled) {
      _showSnack('Messaging is unavailable right now.');
      return;
    }

    final AuthController auth = context.read<AuthController>();
    final user = auth.user;
    if (user == null) {
      _showSnack('Sign in to send a direct message.');
      return;
    }

    setState(() => _isStartingDm = true);
    try {
      final thread = await messages.startThreadWithHandles(<String>[
        widget.post.creatorHandle,
      ], title: displayName.isEmpty ? null : displayName);
      if (!mounted) {
        return;
      }
      await MessageThreadPage.push(
        context,
        threadId: thread.id,
        thread: thread,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack('Unable to start a conversation. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isStartingDm = false);
      }
    }
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      buildThalaSnackBar(
        context,
        icon: Icons.info_outline,
        iconColor: Theme.of(context).colorScheme.secondary,
        semanticsLabel: message,
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileTabs({
    required this.storiesLabel,
    required this.likedLabel,
    required this.mediaLabel,
  });

  final String storiesLabel;
  final String likedLabel;
  final String mediaLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: TabBar(
        labelColor: palette.textPrimary,
        unselectedLabelColor: palette.textMuted,
        dividerColor: palette.border.withValues(alpha: 0.1),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: palette.textPrimary,
            width: 2,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          Tab(text: storiesLabel),
          Tab(text: likedLabel),
          Tab(text: mediaLabel),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.featuredPost,
    required this.displayName,
    required this.handle,
    required this.location,
    required this.bio,
    required this.tags,
    required this.stats,
    required this.actionRow,
  });

  final VideoPost featuredPost;
  final String displayName;
  final String handle;
  final String location;
  final String? bio;
  final List<String> tags;
  final List<_ProfileStat> stats;
  final Widget actionRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final String initial = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : '?';

    final bool isDark = theme.brightness == Brightness.dark;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            handle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          _ProfileStatsRow(stats: stats),
          const SizedBox(height: 16),
          actionRow,
        ],
      ),
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop({required this.post});

  final VideoPost post;

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.surfaceDim, palette.surfaceStrong],
        ),
      ),
    );

    final List<String?> candidates = <String?>[
      post.thumbnailUrl,
      post.imageUrl,
      post.galleryUrls.isNotEmpty ? post.galleryUrls.first : null,
    ];

    String? imageUrl;
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        imageUrl = candidate;
        break;
      }
    }

    if (imageUrl == null) {
      return placeholder;
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({required this.stats});

  final List<_ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        for (int index = 0; index < stats.length; index++) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stats[index].value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                stats[index].label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.textMuted,
                ),
              ),
            ],
          ),
          if (index < stats.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '·',
                style: TextStyle(color: palette.textMuted),
              ),
            ),
        ],
      ],
    );
  }
}

class _ProfileActionsRow extends StatelessWidget {
  const _ProfileActionsRow({
    required this.followButton,
    required this.messageLabel,
    required this.onMessage,
    required this.isMessaging,
    required this.messagingEnabled,
  });

  final Widget followButton;
  final String messageLabel;
  final VoidCallback? onMessage;
  final bool isMessaging;
  final bool messagingEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: followButton),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: (messagingEnabled && !isMessaging) ? onMessage : null,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: theme.colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              messageLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.post});

  final VideoPost post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feed = context.watch<FeedController>();
    final bool isFollowing = feed.isFollowing(post);
    final bool isProcessing = feed.isUpdatePending('${post.id}-follow');
    final String followLabel =
        AppTranslations.of(context, AppText.followAction);
    final String followingLabel =
        AppTranslations.of(context, AppText.followingLabel);

    Future<void> handleFollow() async {
      final auth = context.read<AuthController>();
      final user = auth.user;
      if (user == null) {
        _showSnack(context, 'Sign in to continue.');
        return;
      }
      if (!feed.isRemoteEnabled) {
        _showSnack(context, 'Connect Supabase to continue.');
        return;
      }
      await feed.toggleFollow(post: post, userId: user.id);
    }

    return isFollowing
        ? OutlinedButton(
            onPressed: isProcessing ? null : handleFollow,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: theme.colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              followingLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : FilledButton(
            onPressed: isProcessing ? null : handleFollow,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              followLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          );
  }

  void _showSnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      buildThalaSnackBar(
        context,
        icon: Icons.info_outline,
        iconColor: Theme.of(context).colorScheme.secondary,
        semanticsLabel: message,
      ),
    );
  }
}

class _ProfileStoriesList extends StatelessWidget {
  const _ProfileStoriesList({
    required this.posts,
    required this.locale,
    this.emptyTitle = 'No stories yet',
    this.emptyMessage = 'This creator has not shared any stories yet.',
    this.emptyIcon = Icons.local_movies_outlined,
    required this.scrollController,
  });

  final List<VideoPost> posts;
  final Locale locale;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (posts.isEmpty) {
      return Container(
        color: theme.colorScheme.surface,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          physics: const BouncingScrollPhysics(),
          children: [
            _ProfileEmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
            ),
          ],
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        physics: const BouncingScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _ProfilePostCard(post: post, locale: locale);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 18),
      ),
    );
  }
}

class _ProfileMediaGrid extends StatelessWidget {
  const _ProfileMediaGrid({
    required this.posts,
    required this.locale,
    required this.emptyTitle,
    required this.emptyMessage,
    this.emptyIcon = Icons.collections_outlined,
    required this.scrollController,
  });

  final List<VideoPost> posts;
  final Locale locale;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (posts.isEmpty) {
      return Container(
        color: theme.colorScheme.surface,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
          physics: const BouncingScrollPhysics(),
          children: [
            _ProfileEmptyState(
              icon: emptyIcon,
              title: emptyTitle,
              message: emptyMessage,
            ),
          ],
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.82,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _ProfileMediaCard(post: post, locale: locale);
        },
      ),
    );
  }
}

class _ProfilePostCard extends StatelessWidget {
  const _ProfilePostCard({required this.post, required this.locale});

  final VideoPost post;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final title = post.title.resolve(locale);
    final description = post.description.resolve(locale);
    final double aspect = post.aspectRatio ?? (post.isImage ? 4 / 5 : 16 / 9);

    return ThalaGlassSurface(
      cornerRadius: 28,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: AspectRatio(
              aspectRatio: aspect,
              child: _ProfileMediaPreview(post: post, title: title),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMediaCard extends StatelessWidget {
  const _ProfileMediaCard({required this.post, required this.locale});

  final VideoPost post;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final title = post.title.resolve(locale);

    return ThalaGlassSurface(
      cornerRadius: 24,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: _ProfileMediaPreview(post: post, title: title),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMediaPreview extends StatelessWidget {
  const _ProfileMediaPreview({required this.post, required this.title});

  final VideoPost post;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.thalaPalette;
    final theme = Theme.of(context);
    final Widget placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surfaceDim.withValues(alpha: 0.68),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    final List<String?> candidates = <String?>[
      post.thumbnailUrl,
      post.imageUrl,
      post.galleryUrls.isNotEmpty ? post.galleryUrls.first : null,
    ];

    String? imageUrl;
    for (final candidate in candidates) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        imageUrl = candidate;
        break;
      }
    }

    if (imageUrl == null) {
      return placeholder;
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            placeholder,
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(palette.iconPrimary),
              ),
            ),
          ],
        );
      },
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}

class _ProfileEmptyState extends StatelessWidget {
  const _ProfileEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    return ThalaGlassSurface(
      cornerRadius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 36, color: palette.iconPrimary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;
}

Set<String> _collectTags(List<VideoPost> posts) {
  final Set<String> tags = <String>{};
  for (final VideoPost post in posts) {
    for (final String tag in post.tags) {
      final String trimmed = tag.trim();
      if (trimmed.isNotEmpty) {
        tags.add(trimmed);
      }
    }
  }
  return tags;
}

String? _cleanDescription(String? value) {
  if (value == null) {
    return null;
  }
  final String trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _formatNumber(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toString();
}

MessagesController? _maybeReadMessages(BuildContext context) {
  try {
    return Provider.of<MessagesController>(context, listen: false);
  } on ProviderNotFoundException {
    return null;
  }
}
