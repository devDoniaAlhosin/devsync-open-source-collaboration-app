import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';

class EmptyMatchesWidget extends StatelessWidget {
  const EmptyMatchesWidget({this.onRefresh, super.key});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.inbox, size: 64, color: ds.textMuted),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'No matches yet',
              style: textTheme.titleLarge?.copyWith(
                color: ds.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              'We couldn\'t find any projects matching your skills right now. '
              'Try updating your profile with more skills or check back later.',
              style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onRefresh != null)
                  DsButton(
                    label: 'Refresh',
                    onPressed: onRefresh,
                    icon: AppIcons.refresh,
                    variant: DsButtonVariant.secondary,
                    compact: true,
                  ),
                const SizedBox(width: AppSpacing.md),
                DsButton(
                  label: 'Update Profile',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  icon: AppIcons.user,
                  compact: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
