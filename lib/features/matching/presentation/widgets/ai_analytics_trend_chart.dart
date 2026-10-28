import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_card.dart';

/// Card showing bar chart visual of match relevance trend across sessions.
class AiAnalyticsTrendChart extends StatelessWidget {
  const AiAnalyticsTrendChart({super.key, required this.trendValues});

  final List<double> trendValues;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final maxVal = trendValues.isEmpty
        ? 100.0
        : trendValues.reduce((a, b) => a > b ? a : b);

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
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < trendValues.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
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
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [ds.surfaceAlt, AppColors.teal],
                                ),
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
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Demo values showing how recommendations can improve with feedback.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ds.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
