import 'package:material_ui/material_ui.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/match_item.dart';

class MatchInfoSheet extends StatelessWidget {
  const MatchInfoSheet({super.key, required this.match});
  final MatchItem match;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.xl,
      AppSpacing.sm,
      AppSpacing.xl,
      AppSpacing.xxxl,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${match.score.round()}% match',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          match.reason,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Swipe right to request collaboration or left to skip.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
        ),
      ],
    ),
  );
}
