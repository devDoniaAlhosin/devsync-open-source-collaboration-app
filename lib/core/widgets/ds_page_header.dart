import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shared page intro block used across auth and feature screens.
///
/// Prototype pattern: eyebrow → title → muted body.
class DsPageHeader extends StatelessWidget {
  const DsPageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.body,
    this.titleStyle,
  });

  final String title;
  final String? eyebrow;
  final String? body;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          title,
          style: (titleStyle ?? textTheme.headlineMedium)?.copyWith(
            color: titleStyle?.color ?? ds.textPrimary,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            body!,
            style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
          ),
        ],
      ],
    );
  }
}
