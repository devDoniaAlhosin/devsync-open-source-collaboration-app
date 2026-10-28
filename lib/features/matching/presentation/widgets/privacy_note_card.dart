import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_icon.dart';

class PrivacyNoteCard extends StatelessWidget {
  const PrivacyNoteCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return DsCard(
      tone: DsCardTone.inset,
      borderRadius: AppSpacing.radiusLg,
      child: Row(
        children: [
          const DsIcon(AppIcons.shield, size: 20, color: AppColors.teal),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: ds.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
