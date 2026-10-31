import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_fade_switch.dart';
import '../../domain/entities/match_item.dart';
import '../cubit/matching_cubit.dart';
import '../widgets/ai_studio_content.dart';
import 'ai_analytics_screen.dart';
import 'project_details_screen.dart';

/// Standalone full-screen view of the AI Matching Studio.
class AiMatchingStudioScreen extends StatefulWidget {
  /// Shared [MatchingCubit] from the parent feed. When `null`, owns one from GetIt.
  final MatchingCubit? cubit;

  const AiMatchingStudioScreen({super.key, this.cubit});

  @override
  State<AiMatchingStudioScreen> createState() => _AiMatchingStudioScreenState();
}

class _AiMatchingStudioScreenState extends State<AiMatchingStudioScreen> {
  late final MatchingCubit _cubit;
  late final bool _ownsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: DsAppBar(
          title: 'AI Studio',
          eyebrow: 'DEVSYNC',
          showBack: true,
          onBack: () => Navigator.of(context).maybePop(),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: BlocBuilder<MatchingCubit, MatchingState>(
                builder: (context, state) => _buildBody(context, state),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? getIt<MatchingCubit>();
    if (_ownsCubit) _cubit.loadInitialData();
  }

  Widget _buildBody(BuildContext context, MatchingState state) {
    return AiStudioContent(
      onPromptChanged: _cubit.updatePrompt,
      preferences: state.preferences,
      matches: state.matches,
      scoringBreakdown: state.analytics.scoringBreakdown,
      isGenerating: state.isGenerating,
      onTagToggled: _cubit.toggleTag,
      onGenerateMatches: _generateMatches,
      onViewProjectDetails: (match) => _navigateToProjectDetails(match, state),
      onExploreAnalytics: _openAnalytics,
    );
  }

  Future<void> _generateMatches() async {
    await _cubit.generateMatches();
    if (!mounted) return;
    final state = _cubit.state;
    _notify(
      state.errorMessage ?? '${state.matches.length} matches generated',
    );
  }

  void _navigateToProjectDetails(MatchItem match, MatchingState state) {
    Navigator.of(context).push(
      DsFadePageRoute<void>(
        builder: (_) => ProjectDetailsScreen(
          arguments: ProjectDetailsArguments(
            match: match,
            currentUserSkills: state.profile.declaredSkills,
          ),
        ),
      ),
    );
  }

  void _notify(String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  Future<void> _openAnalytics() async {
    final refreshNeeded = await Navigator.of(context).push<bool>(
      DsFadePageRoute<bool>(
        builder: (_) => AiAnalyticsScreen(cubit: _cubit),
      ),
    );
    if (refreshNeeded == true && mounted) {
      await _cubit.loadInitialData();
    }
  }
}
