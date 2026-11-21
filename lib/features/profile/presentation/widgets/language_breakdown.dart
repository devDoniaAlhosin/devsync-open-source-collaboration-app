import 'dart:math' as math;

import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/presentation/widgets/language_detail_sheet.dart';
import 'package:flutter/material.dart';

class LanguageBreakdown extends StatelessWidget {
  const LanguageBreakdown({
    super.key,
    required this.languages,
    this.profile,
  });

  final List<LanguageShare> languages;

  /// When set, languages are tappable and open a detail sheet.
  final Profile? profile;

  static const double _barHeight = 12;
  static const double _dotSize = 8;

  void _open(BuildContext context, LanguageShare language) {
    final p = profile;
    if (p == null) return;
    LanguageDetailSheet.show(context, language: language, profile: p);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final tappable = profile != null && languages.isNotEmpty;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Languages',
            style: textTheme.titleSmall?.copyWith(
              color: ds.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (tappable) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap a language for repos, commits, and activity.',
              style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (languages.isEmpty) ...[
            _Bar(
              child: ColoredBox(
                color: ds.surfaceAlt,
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Connect GitHub to see your languages.',
              style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
            ),
          ] else ...[
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppAnimations.rise,
              curve: AppAnimations.emphasized,
              builder: (_, t, _) => _Bar(
                child: Row(
                  children: [
                    for (var i = 0; i < languages.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        flex: math.max(1, languages[i].percent),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: tappable
                                ? () => _open(context, languages[i])
                                : null,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: t,
                                child: ColoredBox(
                                  color: Color(languages[i].colorArgb),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final l in languages)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      onTap: tappable ? () => _open(context, l) : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: _dotSize,
                              height: _dotSize,
                              decoration: BoxDecoration(
                                color: Color(l.colorArgb),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm - 2),
                            Text(
                              '${l.name} ${l.percent}%',
                              style: textTheme.bodySmall?.copyWith(
                                color: ds.textMuted,
                                fontWeight: FontWeight.w600,
                                decoration: tappable
                                    ? TextDecoration.underline
                                    : null,
                                decorationColor: ds.border,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: SizedBox(height: LanguageBreakdown._barHeight, child: child),
    );
  }
}
