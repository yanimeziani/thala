import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/feed_controller.dart';
import '../../controllers/messages_controller.dart';
import '../../models/video_post.dart';
import '../../ui/widgets/thela_glass_surface.dart';
import '../../ui/widgets/thela_snackbar.dart';
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
    final palette = context.thelaPalette;
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

    final List<_ProfileStat> stats = <_ProfileStat>[
      _ProfileStat(label: 'Stories', value: _formatNumber(storyCount)),
      _ProfileStat(label: 'Appreciations', value: _formatNumber(totalLikes)),
      _ProfileStat(label: 'Shares', value: _formatNumber(totalShares)),
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
        messagesController != null && messagesController.isSupabaseEnabled;

    final Widget actions = _ProfileActionsRow(
      followButton: _FollowButton(post: widget.post),
      onMessage: messagingEnabled ? () => _startDirectMessage(heroTitle) : null,
      isMessaging: _isStartingDm,
      messagingEnabled: messagingEnabled,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: ThelaPageBackground(
          child: SafeArea(
            top: false,
            bottom: false,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(color: palette.iconPrimary),
                  pinned: true,
                  expandedHeight: 360,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    titlePadding: const EdgeInsetsDirectional.only(
                      start: 72,
                      bottom: 16,
                    ),
                    title: innerBoxIsScrolled
                        ? Text(
                            heroTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                    background: _ProfileHero(
                      featuredPost: featuredPost,
                      displayName: heroTitle,
                      handle: handleLabel,
                      location: location,
                      bio: bio,
                      tags: tags,
                      stats: stats,
                      actionRow: actions,
                    ),
                  ),
                  bottom: const _ProfileTabs(),
                ),
              ],
              body: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _ProfileStoriesList(posts: creatorPosts, locale: locale),
                  _ProfileStoriesList(
                    posts: likedPosts,
                    locale: locale,
                    emptyTitle: 'Nothing liked yet',
                    emptyMessage:
                        'Once you celebrate a story, it will appear here for quick reference.',
                    emptyIcon: Icons.favorite_border,
                  ),
                  _ProfileMediaGrid(posts: mediaPosts, locale: locale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startDirectMessage(String displayName) async {
    final MessagesController? messages = _maybeReadMessages(context);
    if (messages == null || !messages.isSupabaseEnabled) {
      _showSnack('Messaging is unavailable right now.');
      return;
    }

    final AuthController auth = context.read<AuthController>();
    final session = auth.session;
    if (session == null) {
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
      buildThelaSnackBar(
        context,
        icon: Icons.info_outline,
        iconColor: Theme.of(context).colorScheme.secondary,
        semanticsLabel: message,
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileTabs();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final bool isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: ThelaGlassSurface(
        cornerRadius: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: TabBar(
          labelColor: palette.textPrimary,
          unselectedLabelColor: palette.textSecondary,
          indicator: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(
              alpha: isDark ? 0.32 : 0.22,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Stories'),
            Tab(text: 'Liked'),
            Tab(text: 'Media'),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
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
    final palette = context.thelaPalette;
    final String initial = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : '?';

    return Stack(
      fit: StackFit.expand,
      children: [
        _ProfileBackdrop(post: featuredPost),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xAA050506), Color(0xE6000000)],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: ThelaGlassSurface(
              cornerRadius: 32,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.surfaceDim.withValues(alpha: 0.65),
                          border: Border.all(color: palette.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              handle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: palette.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: theme.colorScheme.secondary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: palette.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (bio != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      bio!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: tags.take(6).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: palette.surfaceStrong.withValues(
                              alpha: 0.28,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: palette.border.withValues(alpha: 0.48),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _ProfileStatsRow(stats: stats),
                  const SizedBox(height: 20),
                  actionRow,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop({required this.post});

  final VideoPost post;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
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
    final palette = context.thelaPalette;

    return Row(
      children: [
        for (int index = 0; index < stats.length; index++) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  stats[index].value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  stats[index].label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (index < stats.length - 1)
            Container(
              width: 1,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: palette.border.withValues(alpha: 0.35),
            ),
        ],
      ],
    );
  }
}

class _ProfileActionsRow extends StatelessWidget {
  const _ProfileActionsRow({
    required this.followButton,
    required this.onMessage,
    required this.isMessaging,
    required this.messagingEnabled,
  });

  final Widget followButton;
  final VoidCallback? onMessage;
  final bool isMessaging;
  final bool messagingEnabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: followButton),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: (messagingEnabled && !isMessaging) ? onMessage : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: isMessaging
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : const Icon(Icons.forum_outlined),
            label: Text(
              'Message',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
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

    Future<void> handleFollow() async {
      final auth = context.read<AuthController>();
      final session = auth.session;
      if (session == null) {
        _showSnack(context, 'Sign in to continue.');
        return;
      }
      if (!feed.isRemoteEnabled) {
        _showSnack(context, 'Connect Supabase to continue.');
        return;
      }
      await feed.toggleFollow(post: post, userId: session.user.id);
    }

    return FilledButton.icon(
      onPressed: isProcessing ? null : handleFollow,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: theme.colorScheme.secondary.withValues(
          alpha: isFollowing ? 0.36 : 0.22,
        ),
        foregroundColor: theme.colorScheme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      icon: isProcessing
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onSecondary,
                ),
              ),
            )
          : Icon(
              isFollowing ? Icons.check_circle : Icons.person_add_alt_1,
              color: theme.colorScheme.onSecondary,
            ),
      label: Text(
        isFollowing ? 'Following' : 'Follow',
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.onSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      buildThelaSnackBar(
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
  });

  final List<VideoPost> posts;
  final Locale locale;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _ProfileEmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            message: emptyMessage,
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      physics: const BouncingScrollPhysics(),
      primary: false,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _ProfilePostCard(post: post, locale: locale);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 18),
    );
  }
}

class _ProfileMediaGrid extends StatelessWidget {
  const _ProfileMediaGrid({required this.posts, required this.locale});

  final List<VideoPost> posts;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: const [
          _ProfileEmptyState(
            icon: Icons.collections_outlined,
            title: 'No media yet',
            message:
                'As soon as this creator adds galleries or slides, they will appear here.',
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
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
    final palette = context.thelaPalette;
    final title = post.title.resolve(locale);
    final description = post.description.resolve(locale);
    final double aspect = post.aspectRatio ?? (post.isImage ? 4 / 5 : 16 / 9);

    return ThelaGlassSurface(
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
    final palette = context.thelaPalette;
    final title = post.title.resolve(locale);

    return ThelaGlassSurface(
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
    final palette = context.thelaPalette;
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
    final palette = context.thelaPalette;

    return ThelaGlassSurface(
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
