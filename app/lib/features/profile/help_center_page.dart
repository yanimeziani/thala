import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../../ui/widgets/thela_glass_surface.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const HelpCenterPage()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Help centre'),
        backgroundColor: Colors.transparent,
      ),
      body: ThelaPageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            children: [
              ThelaGlassSurface(
                cornerRadius: 26,
                backgroundOpacity: theme.brightness == Brightness.dark
                    ? 0.24
                    : 0.68,
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Find quick answers about sharing stories, safeguarding culture, and keeping your account secure.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _HelpSection(
                title: 'Recording and uploading stories',
                items: [
                  'Capture stories in portrait. Videos between 15 seconds and 3 minutes play best in the feed.',
                  'Before uploading, collect consent from everyone who appears or whose work is featured.',
                  'Add community tags so guardians can locate stories connected to their lineage.',
                ],
              ),
              const SizedBox(height: 20),
              const _HelpSection(
                title: 'Respecting cultural protocols',
                items: [
                  'Only publish ceremonies, songs, or knowledge that your elders have cleared for public viewing.',
                  'Use the rights and safety form to request takedown of misuse or to add guidance on how to handle sensitive pieces.',
                  'When in doubt about a recording, keep it private and reach out to your community lead for direction.',
                ],
              ),
              const SizedBox(height: 20),
              const _HelpSection(
                title: 'Account and security',
                items: [
                  'You can update your display name, pronouns, and bio any time from Profile details.',
                  'Two-step sign-in is rolling out for guardians. Watch your inbox for activation instructions.',
                  'If you suspect an account breach, sign out of all sessions and email safety@thela.culture.',
                ],
              ),
              const SizedBox(height: 20),
              const _HelpSection(
                title: 'Contact the team',
                items: [
                  'Email support@thela.culture for technical questions or onboarding help.',
                  'Message safety@thela.culture for urgent cultural safety requests.',
                  'Share feature ideas at feedback@thela.culture so we can keep shaping Thela together.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.thelaPalette;
    return ThelaGlassSurface(
      cornerRadius: 22,
      backgroundOpacity: theme.brightness == Brightness.dark ? 0.22 : 0.62,
      borderColor: palette.border,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '-',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
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
