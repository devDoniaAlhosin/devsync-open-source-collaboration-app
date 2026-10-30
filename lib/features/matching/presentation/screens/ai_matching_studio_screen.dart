import 'package:flutter/material.dart';

import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_fade_switch.dart';
import '../../domain/entities/match_item.dart';
import '../../matching_dependencies.dart';
import '../controllers/matching_controller.dart';
import '../widgets/ai_studio_content.dart';
import 'ai_analytics_screen.dart';
import 'project_details_screen.dart';

/// Standalone full-screen view of the AI Matching Studio.
///
/// Presents the "DEVSYNC INTELLIGENCE / BETA" banner, the preferences &
/// prompt card, a ranked suggestions list, and the scoring breakdown with a
/// deep-link into [AiAnalyticsScreen].
///
/// Navigation:
/// - Push via [AppRoutes.aiStudio] or `DsFadePageRoute(builder: (_) => AiMatchingStudioScreen(...))`
/// - Bidirectional: "Explore AI quality analytics" button navigates to
///   [AiAnalyticsScreen]; that screen pops `true` when the prompt is refined,
///   triggering [_controller.loadInitialData] to refresh the match list.
class AiMatchingStudioScreen extends StatefulWidget {
  /// Provide a shared [MatchingController] so this screen stays in sync with
  /// the parent feed. When `null`, the screen owns an isolated controller.
  final MatchingController? controller;

  const AiMatchingStudioScreen({super.key, this.controller});

  @override
  State<AiMatchingStudioScreen> createState() => _AiMatchingStudioScreenState();
}

class _AiMatchingStudioScreenState extends State<AiMatchingStudioScreen> {
  late final MatchingController _controller;
  late final bool _ownsController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _buildBody(context),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _ownsController = widget.controller == null;
    _controller = widget.controller ?? createDemoMatchingController();
    if (_ownsController) _controller.loadInitialData();
  }

  Widget _buildBody(BuildContext context) {
    return AiStudioContent(
      onPromptChanged: _controller.updatePrompt,
      preferences: _controller.preferences,
      matches: _controller.matches,
      scoringBreakdown: _controller.analytics.scoringBreakdown,
      isGenerating: _controller.isGenerating,
      onTagToggled: _controller.toggleTag,
      onGenerateMatches: _generateMatches,
      onViewProjectDetails: _navigateToProjectDetails,
      onExploreAnalytics: _openAnalytics,
    );
  }

  Future<void> _generateMatches() async {
    await _controller.generateMatches();
    if (!mounted) return;
    _notify(
      _controller.errorMessage ??
          '${_controller.matches.length} matches generated',
    );
  }

  void _navigateToProjectDetails(MatchItem match) {
    Navigator.of(context).push(
      DsFadePageRoute<void>(
        builder: (_) => ProjectDetailsScreen(
          arguments: ProjectDetailsArguments(
            match: match,
            currentUserSkills: _controller.profile.declaredSkills,
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
        builder: (_) => AiAnalyticsScreen(controller: _controller),
      ),
    );
    if (refreshNeeded == true && mounted) {
      await _controller.loadInitialData();
    }
  }
}
