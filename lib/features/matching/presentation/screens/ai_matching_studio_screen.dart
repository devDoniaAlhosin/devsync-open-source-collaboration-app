import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon_button.dart';
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
/// - Push via [AppRoutes.aiStudio] or `MaterialPageRoute(builder: (_) => AiMatchingStudioScreen(...))`
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
      appBar: _StudioAppBar(onBack: () => Navigator.of(context).maybePop()),
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
      MaterialPageRoute<void>(
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
      MaterialPageRoute<bool>(
        builder: (_) => AiAnalyticsScreen(controller: _controller),
      ),
    );
    if (refreshNeeded == true && mounted) {
      await _controller.loadInitialData();
    }
  }
}

/// Compact app-bar for the AI Studio screen.
///
/// Shows "DEVSYNC / AI Studio" branding consistent with the match feed's
/// top chrome.
class _StudioAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBack;

  const _StudioAppBar({required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          bottom: AppSpacing.sm,
          top: AppSpacing.sm,
        ),
        child: DsIconButton(
          icon: AppIcons.back,
          tooltip: 'Back',
          onPressed: onBack,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DEVSYNC',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.ds.textMuted,
              letterSpacing: 1.4,
            ),
          ),
          Text(
            'AI Studio',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
