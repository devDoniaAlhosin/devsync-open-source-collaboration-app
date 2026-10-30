import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// How [DsPageHeader] renders the meta line + title.
enum DsPageHeaderStyle {
  /// Auth / marketing: teal uppercase eyebrow + [TextTheme.headlineMedium].
  brand,

  /// List / feature pages: muted sentence-case meta + [TextTheme.displaySmall].
  page,
}

/// Shared page intro block used across auth and feature screens.
///
/// - [DsPageHeaderStyle.brand]: eyebrow → title → muted body
/// - [DsPageHeaderStyle.page]: meta count → large title (+ optional trailing)
class DsPageHeader extends StatelessWidget {
  const DsPageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.body,
    this.titleStyle,
    this.style = DsPageHeaderStyle.brand,
    this.trailing,
  });

  final String title;

  /// Brand: teal uppercase label. Page: muted meta (e.g. `2 listed`).
  final String? eyebrow;
  final String? body;
  final TextStyle? titleStyle;
  final DsPageHeaderStyle style;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final isPage = style == DsPageHeaderStyle.page;

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            isPage ? eyebrow! : eyebrow!.toUpperCase(),
            style: isPage
                ? textTheme.labelMedium?.copyWith(
                    color: ds.textMuted,
                    fontSize: 11.5,
                  )
                : textTheme.labelMedium?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.8,
                  ),
          ),
          SizedBox(height: isPage ? 2 : 8),
        ],
        Text(
          title,
          style: (titleStyle ??
                  (isPage ? textTheme.displaySmall : textTheme.headlineMedium))
              ?.copyWith(
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

    if (trailing == null) return column;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: column),
        trailing!,
      ],
    );
  }
}
