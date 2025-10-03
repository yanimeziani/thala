import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../data/community_profiles_repository.dart';
import '../../data/community_repository.dart';
import '../../data/sample_community_profiles.dart';
import '../../l10n/app_translations.dart';
import '../../models/community_profile.dart';
import '../../ui/widgets/thala_glass_surface.dart';
import '../../ui/widgets/thala_snackbar.dart';
import '../../ui/widgets/thala_logo.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  late final PageController _pageController;
  final CommunityProfilesRepository _profilesRepository =
      CommunityProfilesRepository();
  List<CommunityProfile> _profiles = const <CommunityProfile>[];
  final CommunityRepository _repository = CommunityRepository();
  final Set<String> _recordedCommunities = <String>{};
  bool _isLoading = true;
  String? _errorMessage;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _loadProfiles();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profiles = await _profilesRepository.fetchProfiles();
      final sorted = List<CommunityProfile>.from(profiles)
        ..sort((a, b) => b.priority.compareTo(a.priority));
      setState(() {
        _profiles = sorted;
        _isLoading = false;
        if (!_profilesRepository.isRemoteEnabled) {
          _errorMessage = 'Supabase is not configured. Showing curated communities.';
        }
      });
      if (sorted.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _recordView(0);
        });
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to load community profiles: $error\n$stackTrace');
      setState(() {
        _profiles = const <CommunityProfile>[];
        _isLoading = false;
        _errorMessage = 'Unable to load community profiles.';
      });
    }
  }

  void _recordView(int index) {
    if (index < 0 || index >= _profiles.length) {
      return;
    }
    final profile = _profiles[index];
    if (!_recordedCommunities.add(profile.space.id)) {
      return;
    }
    final auth = context.read<AuthController>();
    final userId = auth.session?.user.id;
    _repository.recordCommunityView(
      communityId: profile.space.id,
      userId: userId,
    );
  }

  Future<void> _handleHostRequest() async {
    HapticFeedback.selectionClick();
    if (!_repository.isRemoteEnabled) {
      HapticFeedback.heavyImpact();
      final message = AppTranslations.of(
        context,
        AppText.communitySupabaseRequired,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        buildThalaSnackBar(
          context,
          icon: Icons.cloud_off,
          iconColor: Theme.of(context).colorScheme.error,
          badgeColor: Theme.of(
            context,
          ).colorScheme.error.withValues(alpha: 0.22),
          semanticsLabel: message,
        ),
      );
      return;
    }

    final data = await _HostRequestSheet.collect(context);
    if (data == null || !mounted) {
      HapticFeedback.selectionClick();
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      final auth = context.read<AuthController>();
      await _repository.submitHostRequest(
        name: data.name,
        email: data.email,
        message: data.message,
        userId: auth.session?.user.id,
      );
      if (!mounted) {
        return;
      }
      final successMessage = AppTranslations.of(
        context,
        AppText.communityHostSuccess,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        buildThalaSnackBar(
          context,
          icon: Icons.send_rounded,
          iconColor: Theme.of(context).colorScheme.secondary,
          semanticsLabel: successMessage,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      HapticFeedback.heavyImpact();
      final errorMessage = AppTranslations.of(
        context,
        AppText.communityHostFailure,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        buildThalaSnackBar(
          context,
          icon: Icons.error_outline,
          iconColor: Theme.of(context).colorScheme.error,
          badgeColor: Theme.of(
            context,
          ).colorScheme.error.withValues(alpha: 0.24),
          semanticsLabel: errorMessage,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final theme = Theme.of(context);
    final palette = context.thalaPalette;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profiles.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Text(
            _errorMessage ?? AppTranslations.of(context, AppText.communityEmpty),
            style: theme.textTheme.bodyLarge,
          ),
        ),
      );
    }

    final activeProfile = _profiles[_activeIndex];
    final activeSummary = activeProfile.space.description
        .resolve(locale)
        .trim();

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: ThalaPageBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommunityHeader(onHostRequest: _handleHostRequest),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: Text(
                    activeSummary.isEmpty
                        ? AppTranslations.of(context, AppText.browseCommunities)
                        : activeSummary,
                    key: ValueKey('${activeProfile.space.id}-$activeSummary'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _activeIndex = index);
                      _recordView(index);
                      HapticFeedback.selectionClick();
                    },
                    itemCount: _profiles.length,
                    itemBuilder: (context, index) {
                      final profile = _profiles[index];
                      return _CommunityCard(
                        profile: profile,
                        locale: locale,
                        isActive: index == _activeIndex,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _PageIndicator(
                  count: _profiles.length,
                  activeIndex: _activeIndex,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _handleHostRequest,
                    icon: const Icon(Icons.send),
                    label: Text(
                      AppTranslations.of(context, AppText.communityHostAction),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityHeader extends StatelessWidget {
  const _CommunityHeader({required this.onHostRequest});

  final VoidCallback onHostRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = AppTranslations.of(context, AppText.communityTab);

    return ThalaGlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      cornerRadius: 24,
      backgroundOpacity: theme.brightness == Brightness.dark ? 0.16 : 0.52,
      enableBorder: false,
      child: Row(
        children: [
          ThalaLogo(
            size: 42,
            fit: BoxFit.contain,
            semanticLabel: AppTranslations.of(context, AppText.appName),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppTranslations.of(context, AppText.browseCommunities),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: AppTranslations.of(context, AppText.communityHostAction),
            onPressed: onHostRequest,
            icon: const Icon(Icons.add_moderator_outlined, size: 22),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard({
    required this.profile,
    required this.locale,
    required this.isActive,
  });

  final CommunityProfile profile;
  final Locale locale;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final space = profile.space;
    final location = space.location.resolve(locale).trim();
    final description = space.description.resolve(locale).trim();
    final languages = profile.languages;
    final tags = <String>{
      ...space.tags,
      ...profile.cards
          .where((card) => card.kind == CommunityCardKind.tags)
          .expand((card) => card.items)
          .map((item) => item.resolve(locale).trim())
          .where((tag) => tag.isNotEmpty),
    }.where((tag) => tag.isNotEmpty).toList(growable: false);
    final detailCards = profile.cards
        .where((card) => card.kind != CommunityCardKind.tags)
        .toList(growable: false);
    final membersLabel = AppTranslations.fromLocale(
      locale,
      AppText.communityMembersLabel,
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 280),
      padding: EdgeInsets.only(
        top: isActive ? 0 : 14,
        bottom: 20,
        left: isActive ? 0 : 6,
        right: isActive ? 0 : 6,
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        scale: isActive ? 1.0 : 0.96,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 240),
          opacity: isActive ? 1.0 : 0.65,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isActive ? 0.22 : 0.1),
                  blurRadius: isActive ? 28 : 18,
                  offset: Offset(0, isActive ? 16 : 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      space.imageUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) =>
                          const ColoredBox(color: Colors.black87),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.black.withOpacity(0.75),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      space.name.resolve(locale),
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.4,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${profile.region} · ${space.memberCount} $membersLabel',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ThalaGlassSurface(
                                enableBorder: false,
                                backgroundColor: Colors.white,
                                backgroundOpacity: 0.14,
                                cornerRadius: 18,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  AppTranslations.of(
                                    context,
                                    AppText.communityFocusLabel,
                                  ),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (location.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.place_outlined,
                                  size: 18,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                                height: 1.45,
                              ),
                            ),
                          ],
                          if (languages.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: languages
                                  .map(
                                    (language) => _PillChip(
                                      label: language,
                                      textColor: Colors.white,
                                      background: Colors.white.withOpacity(
                                        0.16,
                                      ),
                                      borderColor: Colors.white.withOpacity(
                                        0.24,
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(right: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final card in detailCards) ...[
                                    if (card == detailCards.first)
                                      const SizedBox(height: 0)
                                    else
                                      const SizedBox(height: 20),
                                    _CommunitySection(
                                      card: card,
                                      locale: locale,
                                    ),
                                  ],
                                  if (tags.isNotEmpty) ...[
                                    const SizedBox(height: 24),
                                    Text(
                                      'Tags',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: tags
                                          .map(
                                            (tag) => _PillChip(
                                              label: tag,
                                              textColor: Colors.white,
                                              background: Colors.white
                                                  .withOpacity(0.10),
                                              borderColor: Colors.white
                                                  .withOpacity(0.22),
                                            ),
                                          )
                                          .toList(growable: false),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunitySection extends StatelessWidget {
  const _CommunitySection({required this.card, required this.locale});

  final CommunityDetailCard card;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = card.title.resolve(locale).trim();
    final subtitle = card.subtitle?.resolve(locale).trim();
    final body = card.body?.resolve(locale).trim();
    final items = card.items
        .map((item) => item.resolve(locale).trim())
        .where((text) => text.isNotEmpty)
        .toList(growable: false);

    if (title.isEmpty && subtitle == null && body == null && items.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> children = <Widget>[
      Text(
        title.isEmpty ? '—' : title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    ];

    if (subtitle != null && subtitle.isNotEmpty) {
      children
        ..add(const SizedBox(height: 6))
        ..add(
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        );
    }

    if (body != null && body.isNotEmpty) {
      children
        ..add(const SizedBox(height: 10))
        ..add(
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.45,
            ),
          ),
        );
    }

    if (items.isNotEmpty) {
      children
        ..add(const SizedBox(height: 14))
        ..add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white60,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        );
    }

    if (card.links.isNotEmpty) {
      children
        ..add(const SizedBox(height: 14))
        ..add(
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: card.links
                .map((link) => _CommunityLinkPill(link: link))
                .toList(growable: false),
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _CommunityLinkPill extends StatelessWidget {
  const _CommunityLinkPill({required this.link});

  final CommunityLink link;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        HapticFeedback.selectionClick();
        await Clipboard.setData(ClipboardData(text: link.value));
        final message = AppTranslations.of(context, AppText.commonCopied);
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          buildThalaSnackBar(
            context,
            icon: Icons.copy_all_outlined,
            iconColor: theme.colorScheme.secondary,
            badgeColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
            semanticsLabel: '$message · ${link.value}',
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_iconForLink(link.type), size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              link.label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.textColor,
    required this.background,
    required this.borderColor,
  });

  final String label;
  final Color textColor;
  final Color background;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style:
            Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ) ??
            TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 28 : 10,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.secondary
                : theme.colorScheme.secondary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

IconData _iconForLink(CommunityLinkType type) {
  switch (type) {
    case CommunityLinkType.email:
      return Icons.mail_outline;
    case CommunityLinkType.phone:
      return Icons.phone_outlined;
    case CommunityLinkType.website:
      return Icons.language_outlined;
    case CommunityLinkType.facebook:
      return Icons.facebook_outlined;
    case CommunityLinkType.instagram:
      return Icons.photo_camera_outlined;
    case CommunityLinkType.link:
      return Icons.link;
  }
}

class _HostRequestData {
  const _HostRequestData({
    required this.name,
    required this.email,
    required this.message,
  });

  final String name;
  final String email;
  final String message;
}

class _HostRequestSheet extends StatefulWidget {
  const _HostRequestSheet();

  static Future<_HostRequestData?> collect(BuildContext context) {
    return showModalBottomSheet<_HostRequestData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HostRequestSheet(),
    );
  }

  @override
  State<_HostRequestSheet> createState() => _HostRequestSheetState();
}

class _HostRequestSheetState extends State<_HostRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final palette = context.thalaPalette;
    final isDark = context.isDarkMode;
    final sheetColor = isDark
        ? const Color(0xFF0A1216).withValues(alpha: 0.96)
        : palette.surfaceBright.withValues(alpha: 0.98);
    final borderColor = theme.colorScheme.secondary.withValues(
      alpha: isDark ? 0.28 : 0.24,
    );
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: palette.textPrimary,
      fontWeight: FontWeight.bold,
    );
    final descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textSecondary,
    );
    final fieldStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.textPrimary,
    );
    final labelStyle = theme.textTheme.labelLarge?.copyWith(
      color: palette.textSecondary,
      fontWeight: FontWeight.w500,
    );
    String tr(AppText key) => AppTranslations.of(context, key);

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(AppText.communityHostAction), style: titleStyle),
                      const SizedBox(height: 12),
                      Text(
                        tr(AppText.communityHostIntro),
                        style: descriptionStyle,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: tr(AppText.communityHostName),
                          labelStyle: labelStyle,
                        ),
                        style: fieldStyle,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? tr(AppText.commonRequired)
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: tr(AppText.communityHostEmail),
                          labelStyle: labelStyle,
                        ),
                        style: fieldStyle,
                        validator: (value) {
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) {
                            return tr(AppText.commonRequired);
                          }
                          final emailRegExp = RegExp(r'^.+@.+\..+$');
                          return emailRegExp.hasMatch(email)
                              ? null
                              : tr(AppText.commonInvalidEmail);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: tr(AppText.communityHostMessage),
                          labelStyle: labelStyle,
                        ),
                        style: fieldStyle,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? tr(AppText.commonRequired)
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).pop();
                            },
                            child: Text(tr(AppText.commonCancel)),
                          ),
                          const Spacer(),
                          FilledButton(
                            onPressed: _submit,
                            child: Text(tr(AppText.commonSend)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.selectionClick();
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      _HostRequestData(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      ),
    );
  }
}
