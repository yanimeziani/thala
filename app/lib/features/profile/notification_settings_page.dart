import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../controllers/notification_settings_controller.dart';
import '../../models/notification_settings.dart';
import '../../ui/widgets/thela_glass_surface.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  static Future<void> push(BuildContext context) {
    final controller = context.read<NotificationSettingsController>();
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const NotificationSettingsPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationSettingsController>();
    final settings = controller.settings;
    final isLoaded = controller.isLoaded;
    final theme = Theme.of(context);
    final palette = context.thelaPalette;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
      ),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : ThelaPageBackground(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    ThelaGlassSurface(
                      cornerRadius: 26,
                      backgroundOpacity: theme.brightness == Brightness.dark
                          ? 0.24
                          : 0.68,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _NotificationTile(
                            icon: Icons.auto_awesome_outlined,
                            title: 'Story premieres',
                            subtitle:
                                'Be notified when new Amazigh stories go live in your feed.',
                            type: _SettingType.storyAlerts,
                          ),
                          SizedBox(height: 12),
                          _NotificationTile(
                            icon: Icons.groups_outlined,
                            title: 'Community highlights',
                            subtitle:
                                'Weekly digest of guardians, hosts, and cultural events.',
                            type: _SettingType.communityHighlights,
                          ),
                          SizedBox(height: 12),
                          _NotificationTile(
                            icon: Icons.lightbulb_outline,
                            title: 'Product updates',
                            subtitle:
                                'Hear about new features that expand the cultural archive.',
                            type: _SettingType.productUpdates,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!settings.storyAlerts &&
                        !settings.communityHighlights &&
                        !settings.productUpdates)
                      ThelaGlassSurface(
                        cornerRadius: 20,
                        backgroundOpacity: theme.brightness == Brightness.dark
                            ? 0.22
                            : 0.52,
                        borderColor: theme.colorScheme.error,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'All alerts are off. You can still explore Thela manually anytime.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

enum _SettingType { storyAlerts, communityHighlights, productUpdates }

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.type,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final _SettingType type;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationSettingsController>();
    final settings = controller.settings;
    final isEnabled = _valueFor(settings);
    final theme = Theme.of(context);
    final palette = context.thelaPalette;

    return ThelaGlassSurface(
      cornerRadius: 20,
      backgroundOpacity: theme.brightness == Brightness.dark ? 0.24 : 0.62,
      borderColor: palette.border,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: palette.surfaceBright,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: palette.iconPrimary),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.textSecondary,
          ),
        ),
        trailing: Switch.adaptive(
          value: isEnabled,
          activeColor: theme.colorScheme.secondary,
          onChanged: (value) => _setValue(context, value),
        ),
      ),
    );
  }

  bool _valueFor(NotificationSettings settings) {
    switch (type) {
      case _SettingType.storyAlerts:
        return settings.storyAlerts;
      case _SettingType.communityHighlights:
        return settings.communityHighlights;
      case _SettingType.productUpdates:
        return settings.productUpdates;
    }
  }

  Future<void> _setValue(BuildContext context, bool value) {
    final controller = context.read<NotificationSettingsController>();
    switch (type) {
      case _SettingType.storyAlerts:
        return controller.toggleStoryAlerts(value);
      case _SettingType.communityHighlights:
        return controller.toggleCommunityHighlights(value);
      case _SettingType.productUpdates:
        return controller.toggleProductUpdates(value);
    }
  }
}
