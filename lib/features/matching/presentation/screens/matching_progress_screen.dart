import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../cubit/matching_cubit.dart';

/// Runs a refresh and reports the actual operation outcome.
class MatchingProgressScreen extends StatefulWidget {
  const MatchingProgressScreen({super.key, this.cubit});
  final MatchingCubit? cubit;

  @override
  State<MatchingProgressScreen> createState() => _MatchingProgressScreenState();
}

class _MatchingProgressScreenState extends State<MatchingProgressScreen> {
  late final MatchingCubit _cubit;
  late final bool _ownsCubit;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? getIt<MatchingCubit>();
    _cubit.generateMatches();
  }

  @override
  void dispose() {
    if (_ownsCubit) _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: DsAppBar(
      title: 'Refresh matches',
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
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'Loading your profile and requesting ranked projects…',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              if (state.errorMessage != null) {
                return DsEmptyState(
                  icon: AppIcons.error,
                  title: 'Could not refresh matches',
                  message: state.errorMessage,
                  actionLabel: 'Retry',
                  onAction: _cubit.generateMatches,
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.matches.isEmpty
                          ? 'No matches returned'
                          : '${state.matches.length} matches ready',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      state.matches.isEmpty
                          ? 'Add skills or check again when more projects are available.'
                          : 'Your recommendations include scores and reasons from the matching service.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DsButton(
                      label: 'Back to matches',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
