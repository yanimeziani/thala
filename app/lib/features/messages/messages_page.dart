import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/messages_controller.dart';
import '../../l10n/app_translations.dart';
import '../../models/contact_handle.dart';
import '../../models/message_thread.dart';
import '../../ui/widgets/thela_glass_surface.dart';
import 'message_thread_page.dart';
import 'new_message_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MessagesController>();
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');

    final bool isInitialLoad = controller.isLoading && !controller.hasData;
    final bool isSearching = controller.isSearching;
    final String subtitle = AppTranslations.of(
      context,
      controller.isSupabaseEnabled
          ? AppText.messagesSubtitle
          : AppText.messagesConnectSupabase,
    );

    final bool hasSearchQuery = controller.searchQuery.trim().isNotEmpty;
    final bool showSearchResults = hasSearchQuery || isSearching;

    Widget bodyContent;
    if (showSearchResults) {
      bodyContent = _SearchResultsList(
        handles: controller.searchResults,
        isSearching: isSearching,
        onHandleTap: _handleHandleTap,
        searchQuery: controller.searchQuery,
      );
    } else if (isInitialLoad) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (controller.hasData) {
      bodyContent = RefreshIndicator(
        onRefresh: controller.refresh,
        color: palette.iconPrimary,
        backgroundColor: theme.cardColor,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 12, bottom: 32),
          itemCount: controller.threads.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final thread = controller.threads[index];
            return _MessageThreadTile(
              thread: thread,
              locale: locale,
              onTap: () => _handleThreadTap(thread),
            );
          },
        ),
      );
    } else {
      final placeholderKey = controller.isSupabaseEnabled
          ? AppText.messagesEmpty
          : AppText.messagesConnectSupabase;
      bodyContent = _MessagesPlaceholder(
        message: AppTranslations.of(context, placeholderKey),
      );
    }

    final errorMessage = controller.errorMessage;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppTranslations.of(context, AppText.messagesTitle)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: AppTranslations.of(context, AppText.messagesRefresh),
            onPressed: controller.isLoading ? null : () => controller.refresh(),
            icon: controller.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        palette.iconPrimary,
                      ),
                    ),
                  )
                : Icon(Icons.refresh, color: palette.iconPrimary),
          ),
          IconButton(
            tooltip: 'New message',
            onPressed: _startNewMessage,
            icon: Icon(Icons.edit_outlined, color: palette.iconPrimary),
          ),
        ],
      ),
      body: ThelaPageBackground(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              _MessagesHeroCard(
                controller: controller,
                locale: locale,
                subtitle: subtitle,
              ),
              const SizedBox(height: 16),
              _SearchField(
                controller: controller,
                textController: _searchController,
                focusNode: _searchFocusNode,
                onClear: _clearSearch,
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                _BannerMessage(
                  icon: Icons.error_outline,
                  text: errorMessage,
                  color: theme.colorScheme.error,
                ),
              ],
              const SizedBox(height: 16),
              Expanded(child: bodyContent),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleThreadTap(MessageThread thread) async {
    await MessageThreadPage.push(context, threadId: thread.id, thread: thread);
  }

  Future<void> _handleHandleTap(ContactHandle handle) async {
    final controller = context.read<MessagesController>();
    final thread = await controller.startThreadWithHandle(handle);
    if (!mounted) {
      return;
    }
    await MessageThreadPage.push(context, threadId: thread.id, thread: thread);
    if (!mounted) {
      return;
    }
    controller.clearSearch();
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _clearSearch() {
    final controller = context.read<MessagesController>();
    controller.clearSearch();
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  Future<void> _startNewMessage() async {
    final MessagesController controller = context.read<MessagesController>();
    final NewMessageSelection? selection = await NewMessagePage.push(context);
    if (!mounted) {
      return;
    }

    if (selection == null) {
      controller.clearSearch();
      return;
    }

    if (selection.handle != null) {
      await _handleHandleTap(selection.handle!);
      return;
    }

    final String? rawHandle = selection.handleText?.trim();
    if (rawHandle == null || rawHandle.isEmpty) {
      controller.clearSearch();
      return;
    }

    try {
      final MessageThread thread = await controller.startThreadWithHandles(
        <String>[rawHandle],
      );
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
      String message = 'Unable to start conversation. Please try again.';
      if (error is ArgumentError && error.message is String) {
        message = error.message as String;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        controller.clearSearch();
        _searchController.clear();
        _searchFocusNode.unfocus();
      }
    }
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.textController,
    required this.focusNode,
    required this.onClear,
  });

  final MessagesController controller;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onClear;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  String _draft = '';

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textController != widget.textController) {
      oldWidget.textController.removeListener(_onChanged);
      widget.textController.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.textController.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final bool showClear = _draft.isNotEmpty;

    return TextField(
      controller: widget.textController,
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) => widget.controller.searchHandles(value),
      decoration: InputDecoration(
        hintText: 'Search handles or friends',
        prefixIcon: Icon(Icons.search_rounded, color: palette.iconMuted),
        suffixIcon: showClear
            ? IconButton(
                onPressed: widget.onClear,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        filled: true,
        fillColor: palette.surfaceSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _onChanged() {
    final String value = widget.textController.text;
    setState(() => _draft = value);
    widget.controller.searchHandles(value);
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({
    required this.handles,
    required this.isSearching,
    required this.onHandleTap,
    required this.searchQuery,
  });

  final List<ContactHandle> handles;
  final bool isSearching;
  final Future<void> Function(ContactHandle) onHandleTap;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);

    if (isSearching && handles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isSearching && handles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No handles matched "$searchQuery" just yet.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: handles.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final handle = handles[index];
        return ListTile(
          onTap: () => onHandleTap(handle),
          leading: CircleAvatar(
            radius: 20,
            child: Text(handle.displayName.characters.take(2).toString()),
          ),
          title: Text(
            handle.displayName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            handle.bio ?? handle.handle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: palette.iconMuted),
        );
      },
    );
  }
}

class _MessagesHeroCard extends StatelessWidget {
  const _MessagesHeroCard({
    required this.controller,
    required this.locale,
    required this.subtitle,
  });

  final MessagesController controller;
  final Locale locale;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    final highlight = controller.highlightedThread;
    final unread = controller.unreadCount;

    return ThelaGlassSurface(
      cornerRadius: 28,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: palette.surfaceSubtle,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.chat_bubble_outline,
                  color: palette.iconPrimary,
                  size: 24,
                ),
              ),
              if (unread > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.of(context, AppText.messagesTitle),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                if (highlight != null) ...[
                  const SizedBox(height: 12),
                  _ThreadPreview(thread: highlight, locale: locale),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadPreview extends StatelessWidget {
  const _ThreadPreview({required this.thread, required this.locale});

  final MessageThread thread;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final title = _resolveTitle(context, thread, locale);
    final preview = thread.lastMessage.resolve(locale).trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          preview.isNotEmpty
              ? preview
              : AppTranslations.of(context, AppText.messagesEmpty),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.textSecondary,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _MessagesPlaceholder extends StatelessWidget {
  const _MessagesPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MessageThreadTile extends StatelessWidget {
  const _MessageThreadTile({
    required this.thread,
    required this.locale,
    required this.onTap,
  });

  final MessageThread thread;
  final Locale locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final title = _resolveTitle(context, thread, locale);
    final preview = thread.lastMessage.resolve(locale).trim();
    final timeLabel = _formatTimestamp(context, thread.updatedAt);
    final hasUnread = thread.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ThreadAvatar(title: title),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preview.isNotEmpty
                          ? preview
                          : AppTranslations.of(context, AppText.messagesEmpty),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    if (thread.participants.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        thread.participants.join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (timeLabel.isNotEmpty)
                    Text(
                      timeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (hasUnread) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        thread.unreadCount > 99
                            ? '99+'
                            : '${thread.unreadCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThreadAvatar extends StatelessWidget {
  const _ThreadAvatar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    final initials = _initialsFor(title);
    return CircleAvatar(
      radius: 26,
      backgroundColor: palette.surfaceSubtle,
      child: Text(
        initials,
        style: theme.textTheme.titleMedium?.copyWith(
          color: palette.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BannerMessage extends StatelessWidget {
  const _BannerMessage({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _scaleAlpha(color, 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _scaleAlpha(color, 0.24)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _resolveTitle(
  BuildContext context,
  MessageThread thread,
  Locale locale,
) {
  final value = thread.title.resolve(locale).trim();
  if (value.isNotEmpty) {
    return value;
  }
  return AppTranslations.of(context, AppText.messagesFallbackTitle);
}

String _initialsFor(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'T';
  }
  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length == 1) {
    return parts.first.characters.take(1).toString().toUpperCase();
  }
  final first = parts.first.characters.take(1).toString();
  final last = parts.last.characters.take(1).toString();
  return (first + last).toUpperCase();
}

String _formatTimestamp(BuildContext context, DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  final material = MaterialLocalizations.of(context);
  if (difference.inDays < 1) {
    return material.formatTimeOfDay(TimeOfDay.fromDateTime(dateTime));
  }
  if (difference.inDays < 7) {
    return material.formatShortDate(dateTime);
  }
  return material.formatMediumDate(dateTime);
}

Color _scaleAlpha(Color color, double factor) {
  final double ratio = (color.a * factor).clamp(0, 1);
  return color.withAlpha((ratio * 255).round());
}
