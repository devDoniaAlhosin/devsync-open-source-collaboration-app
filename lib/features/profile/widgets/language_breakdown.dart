import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_card.dart';
import '../models/profile_data.dart';

/// Segmented language bar + legend.
class LanguageBreakdown extends StatelessWidget {
  const LanguageBreakdown({super.key, required this.languages});

  final List<LanguageShare> languages;

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
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: AppAnimations.rise,
            curve: AppAnimations.emphasized,
            builder: (_, t, __) => ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    for (var i = 0; i < languages.length; i++) ...[
                      if (i > 0) const SizedBox(width: 3),
                      Expanded(
                        flex: languages[i].percent,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: t,
                            child: Container(color: languages[i].color),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: l.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
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
      ),
    );
  }
}
