import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';

class AiAnalyticsTrendChart extends StatelessWidget {
  const AiAnalyticsTrendChart({
    super.key,
    required this.trendValues,
    this.isDemo = false,
  });

  final List<double> trendValues;

  /// When true, shows a caption below the chart indicating demo values.
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match relevance trend',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.xs),
          if (trendValues.length < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Rate matches on at least two different days to see a trend.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: ds.textMuted),
              ),
            )
          else ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < trendValues.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxVal = trendValues.reduce(
                            (a, b) => a > b ? a : b,
                          );
                          final barHeight =
                              (trendValues[i] / (maxVal > 0 ? maxVal : 1.0)) *
                              (constraints.maxHeight - 8);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: barHeight.clamp(
                                  14.0,
                                  constraints.maxHeight,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.teal,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(AppSpacing.radiusSm),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (isDemo && trendValues.length >= 2) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Demo values showing how recommendations can improve with feedback.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ds.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
