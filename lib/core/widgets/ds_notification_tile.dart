import 'package:material_ui/material_ui.dart';

import '../icons/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_icon.dart';

/// FCM-style notification row (brand guide + prototype `.nt` / `.li`).
class DsNotificationTile extends StatelessWidget {
  const DsNotificationTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.unread = true,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Material(
      color: ds.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: BorderSide(color: ds.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 7),
                decoration: BoxDecoration(
                  color: unread ? AppColors.teal : ds.border,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: ds.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline info / warning banner (prototype `.banner`).
class DsBanner extends StatelessWidget {
  const DsBanner({
    super.key,
    required this.message,
    this.warning = false,
    this.onDismiss,
  });

  final String message;
  final bool warning;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ds.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: ds.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsIcon(
            warning ? AppIcons.warning : AppIcons.info,
            color: warning ? ds.danger : AppColors.teal,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: ds.textPrimary),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: DsIcon(AppIcons.close, size: 18, color: ds.textMuted),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}
