import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';

import '../controllers/feed_controller.dart';
import '../controllers/messages_controller.dart';
import '../l10n/app_translations.dart';
import '../features/create/create_post_page.dart';
import '../features/events/events_page.dart';
import '../features/feed/video_feed_page.dart';
import '../features/messages/messages_page.dart';
import '../features/search/search_page.dart';
import '../services/recommendation_service.dart';
import '../ui/widgets/thela_snackbar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const int _searchTabIndex = 2;

  int _index = 0;
  late final FeedController _feedController;
  late final MessagesController _messagesController;
  late final List<Widget> _pages;
  final GlobalKey<SearchPageState> _searchPageKey = GlobalKey<SearchPageState>();

  @override
  void initState() {
    super.initState();
    final recommendationService = context.read<RecommendationService>();
    _feedController = FeedController(
      recommendationService: recommendationService,
    );
    _messagesController = MessagesController();
    unawaited(_messagesController.ensureLoaded());
    _pages = [
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _feedController),
          ChangeNotifierProvider.value(value: _messagesController),
        ],
        child: const VideoFeedPage(),
      ),
      const EventsPage(),
      SearchPage(key: _searchPageKey),
      ChangeNotifierProvider.value(
        value: _messagesController,
        child: const MessagesPage(),
      ),
    ];
  }

  @override
  void dispose() {
    _messagesController.dispose();
    _feedController.dispose();
    super.dispose();
  }

  void _switchToTab(int newIndex) {
    if (_index == newIndex) {
      if (newIndex == 0) {
        _feedController.setFeedVisibility(true);
      }
      if (newIndex == _searchTabIndex) {
        _focusSearchField();
      }
      return;
    }

    final wasFeedTab = _index == 0;
    final willBeFeedTab = newIndex == 0;
    if (wasFeedTab != willBeFeedTab) {
      _feedController.setFeedVisibility(willBeFeedTab);
    }

    setState(() => _index = newIndex);

    if (newIndex == _searchTabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusSearchField());
    }
  }

  Future<void> _handleCreate() async {
    final post = await CreatePostPage.push(context);
    if (!mounted || post == null) {
      return;
    }
    _feedController.addLocalPost(post);
    if (_index != 0) {
      _switchToTab(0);
    } else {
      _feedController.setFeedVisibility(true);
    }
    final messenger = ScaffoldMessenger.maybeOf(context);
    final message = AppTranslations.of(
      context,
      AppText.createStorySavedLocally,
    );
    messenger?.showSnackBar(
      buildThelaSnackBar(
        context,
        icon: Icons.download_done,
        semanticsLabel: message,
      ),
    );
  }

  void _focusSearchField() {
    _searchPageKey.currentState?.focusSearchField();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface.withAlpha(
      (0.82 * 0xFF).round(),
    );
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _BottomNavBar(
        index: _index,
        backgroundColor: backgroundColor,
        onTap: _switchToTab,
        onCreate: () => unawaited(_handleCreate()),
        messagesController: _messagesController,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.index,
    required this.onTap,
    required this.backgroundColor,
    required this.onCreate,
    required this.messagesController,
  });

  final int index;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final VoidCallback onCreate;
  final MessagesController messagesController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: messagesController,
      builder: (context, _) => _NavBarContents(
        index: index,
        onTap: onTap,
        backgroundColor: backgroundColor,
        onCreate: onCreate,
        messagesController: messagesController,
      ),
    );
  }
}

class _NavBarContents extends StatelessWidget {
  const _NavBarContents({
    required this.index,
    required this.onTap,
    required this.backgroundColor,
    required this.onCreate,
    required this.messagesController,
  });

  final int index;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final VoidCallback onCreate;
  final MessagesController messagesController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final shortestSide = size.shortestSide;
    final isWideLayout = shortestSide >= 600;
    final navHeight = isWideLayout ? 72.0 : 68.0;
    final navBorderRadius = BorderRadius.circular(isWideLayout ? 28.0 : 24.0);
    final navMaxWidth = isWideLayout ? 640.0 : double.infinity;
    final safeHorizontal = isWideLayout ? 24.0 : 16.0;
    final safeBottom = mediaQuery.padding.bottom > 0 ? 12.0 : 16.0;

    final unreadMessages = messagesController.unreadCount;

    final items = [
      _NavItemData(
        index: 0,
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: AppTranslations.of(context, AppText.feedTab),
      ),
      _NavItemData(
        index: 1,
        icon: Icons.event_outlined,
        activeIcon: Icons.event,
        label: AppTranslations.of(context, AppText.eventsTab),
      ),
      _NavItemData(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: AppTranslations.of(context, AppText.createTab),
        onPressed: onCreate,
        isAction: true,
      ),
      _NavItemData(
        index: 2,
        icon: Icons.search_outlined,
        activeIcon: Icons.search,
        label: AppTranslations.of(context, AppText.searchTab),
      ),
      _NavItemData(
        index: 3,
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: AppTranslations.of(context, AppText.messagesTitle),
        badgeCount: unreadMessages > 0 ? unreadMessages : null,
      ),
    ];

    final shouldUseLiquidGlass =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    final navShadows = [
      BoxShadow(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.24 : 0.12,
        ),
        blurRadius: 24,
        offset: const Offset(0, 12),
        spreadRadius: -10,
      ),
    ];
    final navDecoration = BoxDecoration(color: backgroundColor);
    final navContent = SizedBox(
      height: navHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 360;
          final isVeryCompact = width < 320;
          final horizontalPadding =
              isVeryCompact ? 6.0 : (isCompact ? 8.0 : 12.0);
          final itemPadding = EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final item in items)
                Expanded(
                  child: Padding(
                    padding: itemPadding,
                    child: _BottomNavItemButton(
                      data: item,
                      isSelected: item.index != null && item.index == index,
                      colorScheme: colorScheme,
                      onTap: item.onPressed ?? () => onTap(item.index!),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    Widget navSurface = DecoratedBox(
      decoration: navDecoration,
      child: navContent,
    );
    if (shouldUseLiquidGlass) {
      final radiusValue = navBorderRadius.topLeft.x;
      navSurface = LiquidGlass(
        glassContainsChild: false,
        shape: LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(radiusValue),
        ),
        settings: const LiquidGlassSettings(
          thickness: 12,
          blur: 24,
          glassColor: Color(0x26FFFFFF),
          lightIntensity: 1.32,
          ambientStrength: 0.52,
          blend: 38,
          saturation: 1.08,
          lightness: 1.04,
        ),
        child: navSurface,
      );
    }

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(
        safeHorizontal,
        0,
        safeHorizontal,
        safeBottom,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: navMaxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: navBorderRadius,
              boxShadow: navShadows,
            ),
            child: ClipRRect(borderRadius: navBorderRadius, child: navSurface),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    this.index,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.onPressed,
    this.isAction = false,
    this.badgeCount,
  }) : assert(
         index != null || onPressed != null,
         'Navigation items must provide either an index or an onPressed action.',
       );

  final int? index;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback? onPressed;
  final bool isAction;
  final int? badgeCount;
}

class _BottomNavItemButton extends StatelessWidget {
  const _BottomNavItemButton({
    required this.data,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  final _NavItemData data;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final isAction = data.isAction;
    final iconBaseColor = palette.textPrimary;
    final inactiveOpacity = 0.52;
    const iconSize = 26.0;
    const actionSizeBoost = 1.10; // create button stands out slightly more than the rest
    final actionIconSize = iconSize * actionSizeBoost;
    final actionButtonSize = 52.0 * actionSizeBoost;
    final splashColor = palette.overlay.withValues(alpha: isAction ? 0.16 : 0.10);

    Widget icon = Icon(
      isSelected ? data.activeIcon : data.icon,
      color: isAction ? colorScheme.onPrimary : iconBaseColor,
      size: isAction ? actionIconSize : iconSize,
    );

    if (!isAction) {
      icon = AnimatedOpacity(
        opacity: isSelected ? 1 : inactiveOpacity,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: icon,
      );
    } else {
      icon = AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: Container(
          key: ValueKey<bool>(isSelected),
          height: actionButtonSize,
          width: actionButtonSize,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.32),
                blurRadius: 16,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      );
    }

    if (!isAction) {
      icon = SizedBox(width: 32, child: Center(child: icon));
    }

    if (!isAction) {
      final badgeCount = data.badgeCount ?? 0;
      if (badgeCount > 0) {
        final badgeLabel = badgeCount > 99 ? '99+' : '$badgeCount';
        icon = Stack(
          clipBehavior: Clip.none,
          children: [
            icon,
            Positioned(
              top: -8,
              right: -10,
              child: _NavBadge(
                label: badgeLabel,
                backgroundColor: colorScheme.secondary,
                foregroundColor: colorScheme.onSecondary,
              ),
            ),
          ],
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Semantics(
        label: data.label,
        selected: isSelected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(
              isAction ? actionButtonSize / 2 : 18.0,
            ),
            splashColor: splashColor,
            highlightColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isAction ? 12.0 : 0.0,
                vertical: isAction ? 6.0 : 12.0,
              ),
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  const _NavBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ) ??
        TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: textStyle, textAlign: TextAlign.center),
    );
  }
}
