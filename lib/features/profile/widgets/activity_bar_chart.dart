import 'package:flutter/material.dart';

import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_card.dart';
import '../models/insights_data.dart';

class ActivityBarChart extends StatelessWidget {
  const ActivityBarChart({
    super.key,
    required this.period,
    required this.bars,
    required this.onPeriodChanged,
  });

  final InsightsPeriod period;
  final List<BarPoint> bars;
  final ValueChanged<InsightsPeriod> onPeriodChanged;

  static const double _chartHeight = 150;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    final maxValue = bars.fold<int>(1, (m, b) => b.value > m ? b.value : m);
    final dense = bars.length > 8;

    return DsCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Activity',
                  style: textTheme.titleMedium?.copyWith(
                    color: ds.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              PopupMenuButton<InsightsPeriod>(
                tooltip: 'Change period',
                initialValue: period,
                onSelected: onPeriodChanged,
                color: ds.surface,
                itemBuilder: (_) => [
                  for (final p in InsightsPeriod.values)
                    PopupMenuItem(value: p, child: Text(p.longLabel)),
                ],
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: ds.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        period.longLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: ds.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: ds.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            label: 'Activity chart, ${period.longLabel}',
            child: KeyedSubtree(
              key: ValueKey(period),
              child: Column(
                children: [
                  SizedBox(
                    height: _chartHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final b in bars)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: dense ? 2 : 6,
                              ),
                              child: _Bar(fraction: b.value / maxValue),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      for (final b in bars)
                        Expanded(
                          child: Text(
                            b.label,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: textTheme.bodySmall?.copyWith(
                              color: ds.textMuted,
                              fontSize: dense ? 9 : 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraction.clamp(0.04, 1.0)),
      duration: AppAnimations.rise,
      curve: AppAnimations.emphasized,
      builder: (_, f, __) => Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: f,
          widthFactor: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
                bottom: Radius.circular(3),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.teal.withValues(alpha: 0.35),
                  AppColors.teal,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
