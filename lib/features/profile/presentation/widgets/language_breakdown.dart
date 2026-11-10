import 'dart:math' as math;

import 'package:devsync_open_source_collaboration_app/core/theme/app_animations.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_card.dart';
import 'package:devsync_open_source_collaboration_app/features/profile/domain/entities/profile.dart';
import 'package:flutter/material.dart';

class LanguageBreakdown extends StatelessWidget {
  const LanguageBreakdown({super.key, required this.languages});

  final List<LanguageShare> languages;

  static const double _barHeight = 12;
  static const double _dotSize = 8;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

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
                        // flex must be > 0 or the segment disappears.
                        flex: math.max(1, languages[i].percent),
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
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.sm,
              children: [
                for (final l in languages)
                  Row(
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
