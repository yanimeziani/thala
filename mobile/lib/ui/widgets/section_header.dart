import 'package:flutter/material.dart';

/// Lightweight, theme-aware header used to keep page intros consistent.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
    this.spacing = 12,
  });

  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final resolvedPadding = padding ?? EdgeInsets.zero;
    final theme = Theme.of(context);

    return Padding(
      padding: resolvedPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null)
            Padding(
              padding: EdgeInsets.only(right: spacing),
              child: leading,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultTextStyle.merge(
                  style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  child: title,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle.merge(
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (action != null)
            Flexible(
              flex: 0,
              child: Padding(
                padding: EdgeInsets.only(left: spacing),
                child: action!,
              ),
            ),
        ],
      ),
    );
  }
}
