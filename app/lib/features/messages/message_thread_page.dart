import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/messages_controller.dart';
import '../../models/message.dart';
import '../../models/message_thread.dart';

class MessageThreadPage extends StatefulWidget {
  const MessageThreadPage({
    super.key,
    required this.threadId,
    this.initialThread,
  });

  final String threadId;
  final MessageThread? initialThread;

  static Future<void> push(
    BuildContext context, {
    required String threadId,
    MessageThread? thread,
  }) {
    final MessagesController controller = context.read<MessagesController>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider<MessagesController>.value(
          value: controller,
          child: MessageThreadPage(threadId: threadId, initialThread: thread),
        ),
      ),
    );
  }

  @override
  State<MessageThreadPage> createState() => _MessageThreadPageState();
}

class _MessageThreadPageState extends State<MessageThreadPage> {
  final TextEditingController _composerController = TextEditingController();
  final FocusNode _composerFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  int _lastMessageCount = 0;
  bool _markReadQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final MessagesController controller = context.read<MessagesController>();
      controller.ensureThreadLoaded(widget.threadId);
      controller.markThreadRead(widget.threadId);
    });
  }

  @override
  void dispose() {
    _composerController.dispose();
    _composerFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MessagesController controller = context.watch<MessagesController>();
    MessageThread? thread = widget.initialThread;
    for (final MessageThread candidate in controller.threads) {
      if (candidate.id == widget.threadId) {
        thread = candidate;
        break;
      }
    }
    final List<Message> messages = controller.messagesForThread(
      widget.threadId,
    );
    final bool isLoading = controller.isThreadLoading(widget.threadId);
    final bool isSending = controller.isThreadSending(widget.threadId);
    final String? threadError = controller.threadError(widget.threadId);

    if (_lastMessageCount != messages.length) {
      _lastMessageCount = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
      _queueMarkRead(controller);
    }

    final theme = Theme.of(context);
    final palette = context.thelaPalette;

    return Scaffold(
      appBar: AppBar(
        title: _ThreadTitle(thread: thread, controller: controller),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          if (threadError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _ErrorBanner(
                text: threadError,
                onDismissed: () => controller.clearThreadError(widget.threadId),
              ),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: messages.isEmpty
                  ? _EmptyConversation(palette: palette)
                  : _MessageList(
                      key: ValueKey<int>(messages.length),
                      controller: _scrollController,
                      messages: messages,
                    ),
            ),
          ),
          _MessageComposer(
            controller: controller,
            threadId: widget.threadId,
            textController: _composerController,
            focusNode: _composerFocusNode,
            isSending: isSending,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _scrollToEnd() {
    if (!_scrollController.hasClients) {
      return;
    }
    final double offset = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _queueMarkRead(MessagesController controller) {
    if (_markReadQueued) {
      return;
    }
    _markReadQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _markReadQueued = false;
      await controller.markThreadRead(widget.threadId);
    });
  }
}

class _ThreadTitle extends StatelessWidget {
  const _ThreadTitle({required this.thread, required this.controller});

  final MessageThread? thread;
  final MessagesController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    final MessageThread? value = thread;
    if (value == null) {
      return Text(
        controller.currentUser.displayName,
        style: theme.textTheme.titleMedium?.copyWith(
          color: palette.textPrimary,
        ),
      );
    }

    final String title = value.title.resolve(
      Localizations.maybeLocaleOf(context) ?? const Locale('en'),
    );
    final String subtitle = value.participants.join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title.isEmpty ? 'Conversation' : title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    super.key,
    required this.controller,
    required this.messages,
  });

  final ScrollController controller;
  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        final Message message = messages[index];
        final Message? previous = index > 0 ? messages[index - 1] : null;
        final bool showDateSeparator = previous == null
            ? true
            : !_isSameDay(message.createdAt, previous.createdAt);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showDateSeparator)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _DateChip(dateTime: message.createdAt),
              ),
            _MessageBubble(
              message: message,
              isLastInSeries: _isLastMessageInSeries(messages, index),
              showAuthor: _shouldShowAuthor(message, previous),
            ),
          ],
        );
      },
    );
  }

  bool _isLastMessageInSeries(List<Message> list, int index) {
    if (index == list.length - 1) {
      return true;
    }
    final Message current = list[index];
    final Message next = list[index + 1];
    return current.isMine != next.isMine ||
        next.createdAt.difference(current.createdAt).inMinutes > 3;
  }

  bool _shouldShowAuthor(Message message, Message? previous) {
    if (message.isMine) {
      return false;
    }
    if (previous == null) {
      return true;
    }
    if (previous.authorHandle != message.authorHandle) {
      return true;
    }
    return message.createdAt.difference(previous.createdAt).inMinutes > 8;
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isLastInSeries,
    required this.showAuthor,
  });

  final Message message;
  final bool isLastInSeries;
  final bool showAuthor;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    final Color bubbleColor = message.isMine
        ? theme.colorScheme.primary
        : palette.surfaceSubtle;
    final Color textColor = message.isMine
        ? theme.colorScheme.onPrimary
        : palette.textPrimary;

    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(22),
      topRight: const Radius.circular(22),
      bottomLeft: Radius.circular(message.isMine ? 22 : 6),
      bottomRight: Radius.circular(message.isMine ? 6 : 22),
    );

    final MaterialLocalizations materials = MaterialLocalizations.of(context);
    final String timeLabel = materials.formatTimeOfDay(
      TimeOfDay.fromDateTime(message.createdAt),
      alwaysUse24HourFormat: false,
    );
    final String? statusLabel = message.isMine
        ? _statusLabel(message.deliveryStatus)
        : null;

    return Padding(
      padding: EdgeInsets.only(
        left: message.isMine ? 80 : 0,
        right: message.isMine ? 0 : 80,
        bottom: isLastInSeries ? 12 : 4,
      ),
      child: Align(
        alignment: message.isMine
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showAuthor)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.authorDisplayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _scaleAlpha(textColor, 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Text(
                  message.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      timeLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _scaleAlpha(textColor, 0.7),
                        fontSize: 11,
                      ),
                    ),
                    if (statusLabel != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _scaleAlpha(textColor, 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _scaleAlpha(Color color, double factor) {
    final double ratio = (color.a * factor).clamp(0, 1);
    return color.withAlpha((ratio * 255).round());
  }

  String? _statusLabel(MessageDeliveryStatus status) {
    switch (status) {
      case MessageDeliveryStatus.pending:
        return 'Sending…';
      case MessageDeliveryStatus.sent:
        return 'Sent';
      case MessageDeliveryStatus.delivered:
        return 'Delivered';
      case MessageDeliveryStatus.read:
        return 'Read';
      case MessageDeliveryStatus.failed:
        return 'Failed';
    }
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({
    required this.controller,
    required this.threadId,
    required this.textController,
    required this.focusNode,
    required this.isSending,
  });

  final MessagesController controller;
  final String threadId;
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool isSending;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  late String _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.textController.text;
    widget.textController.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant _MessageComposer oldWidget) {
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
    final theme = Theme.of(context);
    final palette = context.thelaPalette;

    final bool canSend = _draft.trim().isNotEmpty && !widget.isSending;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: palette.surfaceSubtle)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.textController,
                focusNode: widget.focusNode,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 6,
                onSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: 'Message',
                  filled: true,
                  fillColor: palette.surfaceSubtle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: canSend ? _handleSend : null,
              style: IconButton.styleFrom(
                backgroundColor: canSend
                    ? theme.colorScheme.primary
                    : palette.surfaceSubtle,
                foregroundColor: canSend
                    ? theme.colorScheme.onPrimary
                    : palette.textSecondary,
              ),
              icon: widget.isSending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          canSend
                              ? theme.colorScheme.onPrimary
                              : palette.textSecondary,
                        ),
                      ),
                    )
                  : const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }

  void _onChanged() {
    setState(() => _draft = widget.textController.text);
  }

  Future<void> _handleSend() async {
    final String text = widget.textController.text.trim();
    if (text.isEmpty || widget.isSending) {
      return;
    }
    await widget.controller.sendMessage(widget.threadId, text);
    if (mounted && widget.controller.threadError(widget.threadId) == null) {
      widget.textController.clear();
      widget.focusNode.requestFocus();
    }
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.dateTime});

  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    final MaterialLocalizations materials = MaterialLocalizations.of(context);
    final String label = materials.formatFullDate(dateTime);
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: palette.surfaceSubtle,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: palette.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  const _EmptyConversation({required this.palette});

  final ThelaPalette palette;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'This space is ready for new stories. Send a message to begin.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text, required this.onDismissed});

  final String text;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final theme = Theme.of(context);
    return Material(
      color: palette.surfaceSubtle,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onDismissed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.close_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
