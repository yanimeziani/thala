import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/messages_controller.dart';
import '../../models/contact_handle.dart';
import '../../ui/widgets/thela_glass_surface.dart';

typedef NewMessageSelection = ({ContactHandle? handle, String? handleText});

class NewMessagePage extends StatefulWidget {
  const NewMessagePage({super.key});

  static Future<NewMessageSelection?> push(BuildContext context) {
    final MessagesController controller = context.read<MessagesController>();
    return Navigator.of(context).push<NewMessageSelection>(
      MaterialPageRoute<NewMessageSelection>(
        builder: (_) => ChangeNotifierProvider<MessagesController>.value(
          value: controller,
          child: const NewMessagePage(),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<NewMessagePage> createState() => _NewMessagePageState();
}

class _NewMessagePageState extends State<NewMessagePage> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final MessagesController _messagesController;
  String _draft = '';

  @override
  void initState() {
    super.initState();
    _messagesController = context.read<MessagesController>();
    _messagesController.clearSearch();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _messagesController.clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.thelaPalette;
    final MessagesController controller = context.watch<MessagesController>();
    final List<ContactHandle> handles = controller.searchResults;
    final bool isSearching = controller.isSearching;
    final String query = controller.searchQuery;

    return Scaffold(
      appBar: AppBar(title: const Text('New message')),
      body: ThelaPageBackground(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onSubmitted: _handleSubmit,
                decoration: InputDecoration(
                  hintText: 'Search handles or enter a handle',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: palette.iconMuted,
                  ),
                  suffixIcon: _draft.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _clearDraft,
                          icon: const Icon(Icons.close_rounded),
                        ),
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
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _NewMessageResults(
                  handles: handles,
                  isSearching: isSearching,
                  onHandleTap: _handleHandleTap,
                  onSubmitText: _handleSubmit,
                  query: query,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChanged() {
    final String value = _searchController.text;
    setState(() => _draft = value);
    _messagesController.searchHandles(value);
  }

  void _handleSubmit(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    Navigator.of(context).pop((handle: null, handleText: trimmed));
  }

  void _handleHandleTap(ContactHandle handle) {
    Navigator.of(context).pop((handle: handle, handleText: null));
  }

  void _clearDraft() {
    _searchController.clear();
    _handleChanged();
    _searchFocusNode.requestFocus();
  }
}

class _NewMessageResults extends StatelessWidget {
  const _NewMessageResults({
    required this.handles,
    required this.isSearching,
    required this.onHandleTap,
    required this.onSubmitText,
    required this.query,
  });

  final List<ContactHandle> handles;
  final bool isSearching;
  final void Function(ContactHandle handle) onHandleTap;
  final void Function(String handleText) onSubmitText;
  final String query;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final palette = context.thelaPalette;
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final String trimmed = query.trim();
    final bool showStartOption = trimmed.isNotEmpty;
    final bool hasMatches = handles.isNotEmpty;

    if (!hasMatches && !isSearching && trimmed.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: 12, right: 12, bottom: bottomInset + 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, color: palette.iconMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              'Search for a friend or enter a handle to begin a new conversation.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final List<Widget> children = <Widget>[];

    if (showStartOption) {
      children.add(
        ListTile(
          onTap: () => onSubmitText(trimmed),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: palette.surfaceSubtle,
            child: Icon(Icons.edit_outlined, color: palette.iconPrimary),
          ),
          title: Text(
            'Start conversation with "$trimmed"',
            style: theme.textTheme.titleSmall?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            'Send a message to this handle',
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
      );
      if (hasMatches) {
        children.add(const Divider(height: 1));
      }
    }

    for (int index = 0; index < handles.length; index++) {
      final ContactHandle handle = handles[index];
      children.add(
        ListTile(
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
        ),
      );
      if (index < handles.length - 1) {
        children.add(const Divider(height: 1));
      }
    }

    if (isSearching && handles.isEmpty) {
      children.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (!isSearching && handles.isEmpty && trimmed.isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Text(
            'No handles matched "$trimmed" yet. Try a different handle or invite your friend to join.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ),
      );
    }

    final double bottomPadding = bottomInset > 0 ? bottomInset + 16 : 24;

    return ListView(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
      children: children,
    );
  }
}
