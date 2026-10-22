import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_card.dart';
import '../../../core/widgets/ds_chip.dart';
import '../../../core/widgets/ds_github_icon.dart';

/// "nour-dev is connected · Last scanned today · Verified".
class GithubConnectionCard extends StatelessWidget {
  const GithubConnectionCard({
    super.key,
    required this.username,
    this.lastScanned = 'Last scanned today',
    this.verified = true,
  });

  final String username;
  final String lastScanned;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

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
