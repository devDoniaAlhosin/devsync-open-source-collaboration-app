import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_button.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_chip.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_github_icon.dart';

class GithubConnectionCard extends StatelessWidget {
  const GithubConnectionCard({
    super.key,
    required this.username,
    this.lastScanned = 'Last scanned today',
    this.verified = true,
    this.onConnect,
  });

  final String username;
  final String lastScanned;
  final bool verified;
  final VoidCallback? onConnect;

  bool get _connected => username.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    if (!_connected) {
      return DsCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DsGithubIcon(size: 26, color: ds.textMuted),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GitHub not connected',
                        style: textTheme.titleSmall?.copyWith(
                          color: ds.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Link your public profile for better matches.',
                        style: textTheme.bodySmall?.copyWith(
                          color: ds.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onConnect != null) ...[
              const SizedBox(height: AppSpacing.md),
              DsButton(
                label: 'Connect GitHub',
                leading: const DsGithubIcon(size: 18, color: AppColors.onTeal),
                onPressed: onConnect,
                compact: true,
              ),
            ],
          ],
        ),
      );
    }

    return DsCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: [
          const DsGithubIcon(size: 26, color: AppColors.teal),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: username,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(text: ' is connected'),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: ds.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lastScanned,
                  style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                ),
              ],
            ),
          ),
          if (verified) ...[
            const SizedBox(width: AppSpacing.sm),
            const DsChip(label: 'Verified', variant: DsChipVariant.selected),
          ],
        ],
      ),
    );
  }
}
