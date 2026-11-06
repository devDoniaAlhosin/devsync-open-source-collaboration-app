import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../cubit/matching_cubit.dart';
import '../widgets/ai_analytics_stat_card.dart';
import '../widgets/ai_analytics_transparency_card.dart';
import 'prompt_quality_screen.dart';

/// Displays analytics and insights for recent match results.
class AiAnalyticsScreen extends StatefulWidget {
  const AiAnalyticsScreen({super.key, this.cubit});
  final MatchingCubit? cubit;

  @override
  State<AiAnalyticsScreen> createState() => _AiAnalyticsScreenState();
}

class _AiAnalyticsScreenState extends State<AiAnalyticsScreen> {
  late final MatchingCubit _cubit;
  late final bool _ownsCubit;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? getIt<MatchingCubit>();
    if (_ownsCubit) _cubit.loadInitialData();
  }

  @override
  void dispose() {
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DsAppBar(
      title: 'Match insights',
      eyebrow: 'DEVSYNC',
      showBack: true,
      onBack: () => Navigator.of(context).maybePop(),
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: BlocBuilder<MatchingCubit, MatchingState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.isLoading || state.isGenerating) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.errorMessage != null) {
                return DsEmptyState(
                  icon: AppIcons.error,
                  title: 'Could not load insights',
                  message: state.errorMessage,
                  actionLabel: 'Retry',
                  onAction: _cubit.loadInitialData,
                );
              }
              final matches = state.matches;
              final average = matches.isEmpty
                  ? null
                  : matches.fold<double>(0, (sum, match) => sum + match.score) /
                        matches.length;
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  Text(
                    'Recommendation insights',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text('Results from your latest matching request.'),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AiAnalyticsStatCard(
                        value: '${matches.length}',
                        label: 'Projects returned',
                      ),
                      AiAnalyticsStatCard(
                        value: average == null ? '—' : '${average.round()}%',
                        label: 'Average match',
                      ),
                      AiAnalyticsStatCard(
                        value:
                            '${matches.where((match) => match.isFallback).length}',
                        label: 'Skill-based matches',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (matches.isEmpty)
                    const Text(
                      'No matches yet. Add skills to your profile or try again later.',
                    ),
                  if (state.promptVersion != null) ...[
                    Text('Scoring version: ${state.promptVersion}'),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  const AiAnalyticsTransparencyCard(),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PromptQualityScreen(),
                      ),
                    ),
                    child: const Text('About prompt quality'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
