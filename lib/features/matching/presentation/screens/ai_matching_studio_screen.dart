import 'package:material_ui/material_ui.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../../data/datasources/matching_local_data_source.dart';
import '../../data/datasources/matching_remote_data_source.dart';
import '../../data/repositories/matching_repository_impl.dart';
import '../../domain/entities/match_item.dart';
import '../controllers/matching_controller.dart';
import '../widgets/ai_studio_preferences_card.dart';
import '../widgets/ai_studio_scoring_card.dart';
import '../widgets/ai_studio_suggested_matches_card.dart';
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
  late final TextEditingController _promptTextController;

  // ── Build ────────────────────────────────────────────────────────────────

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
    _controller.removeListener(_syncPromptController);
    _promptTextController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      final repository = MatchingRepositoryImpl(
        remoteDataSource: MockMatchingRemoteDataSource(),
        localDataSource: InMemoryMatchingLocalDataSource(),
      );
      _controller = MatchingController(repository: repository);
      _ownsController = true;
      _controller.loadInitialData();
    }

    _promptTextController = TextEditingController(
      text: _controller.preferences.prompt,
    );
    _promptTextController.addListener(_onPromptTextChanged);
    _controller.addListener(_syncPromptController);
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── "DEVSYNC INTELLIGENCE / BETA" banner ──────────────────────
          const _IntelligenceBanner(),
          const SizedBox(height: AppSpacing.md),

          // ── Match preferences (prompt + skill tags + generate button) ─
          AiStudioPreferencesCard(
            promptController: _promptTextController,
            selectedTags: _controller.preferences.selectedTags,
            onTagToggled: _controller.toggleTag,
            isGenerating: _controller.isGenerating,
            onGenerateMatches: () async {
              await _controller.generateMatches();
              if (mounted) {
                _notify('${_controller.matches.length} matches generated');
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Suggested matches list ────────────────────────────────────
          AiStudioSuggestedMatchesCard(
            matches: _controller.matches,
            onViewProjectDetails: _navigateToProjectDetails,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Scoring breakdown + analytics CTA ─────────────────────────
          AiStudioScoringCard(
            breakdown: _controller.analytics.scoringBreakdown,
            onExploreAnalytics: _openAnalytics,
          ),
        ],
      ),
    );
  }

  // ── Navigation helpers ───────────────────────────────────────────────────

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

  void _onPromptTextChanged() {
    _controller.updatePrompt(_promptTextController.text);
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

  void _syncPromptController() {
    if (_promptTextController.text != _controller.preferences.prompt) {
      _promptTextController.text = _controller.preferences.prompt;
    }
  }
}

// ── Private sub-widgets ──────────────────────────────────────────────────────

/// Pill-shaped banner showing "DEVSYNC INTELLIGENCE / BETA".
class _IntelligenceBanner extends StatelessWidget {
  const _IntelligenceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: context.ds.surface,
        border: Border.all(color: context.ds.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: const Row(
        children: [
          DsIcon(AppIcons.sparkle, color: AppColors.teal, size: 16),
          SizedBox(width: AppSpacing.sm),
          Text(
            'DEVSYNC INTELLIGENCE / BETA',
            style: TextStyle(
              color: AppColors.teal,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
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
