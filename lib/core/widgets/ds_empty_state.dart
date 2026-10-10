import 'package:flutter/material.dart';

import '../icons/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_button.dart';
import 'ds_icon.dart';

/// Placeholder for empty lists / feeds.
class DsEmptyState extends StatelessWidget {
  const DsEmptyState({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon = AppIcons.inbox,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsIcon(icon, size: 48, color: ds.textMuted),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(color: ds.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              DsButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
