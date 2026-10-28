import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/matching_progress_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../domain/entities/match_item.dart';
import '../../matching_dependencies.dart';
import '../controllers/matching_controller.dart';
import '../widgets/ai_studio_content.dart';
import '../widgets/draggable_match_card.dart';
import '../widgets/explore_devsync_section.dart';
import '../widgets/match_card_skeleton.dart';
import '../widgets/match_feed_app_bar.dart';
import '../widgets/match_feed_deck_view.dart';
import '../widgets/match_feed_empty_state.dart';
import '../widgets/match_feed_greeting.dart';
import '../widgets/match_info_sheet.dart';
import 'ai_analytics_screen.dart';
import 'ai_matching_studio_screen.dart';
import 'project_details_screen.dart';
import 'prompt_quality_screen.dart';

/// Screen hosting the AI recommendations and interactive match feed.
///
/// Follows Clean Architecture and SOLID standards by delegating state and
/// business logic to [MatchingController] and separating presentation into
/// focused reusable widgets.
class MatchFeedScreen extends StatefulWidget {
  final MatchingController? controller;
  final MatchingViewMode? initialViewMode;

  const MatchFeedScreen({super.key, this.controller, this.initialViewMode});

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  late final MatchingController _controller;
  late final bool _ownsController;
  final GlobalKey<DraggableMatchCardState> _cardKey =
      GlobalKey<DraggableMatchCardState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final page = SafeArea(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildPageContent(),
      ),
    );
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(body: page),
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

    final initialMode = widget.initialViewMode ?? MatchingViewMode.deck;
    _controller.setViewMode(initialMode);
  }

  Widget _buildContent() {
    if (_controller.isLoading) return const Center(child: MatchCardSkeleton());
    final error = _controller.errorMessage;
    if (error != null) {
      return DsEmptyState(
        icon: AppIcons.error,
        title: 'Something went wrong',
        message: error,
        actionLabel: 'Retry',
        onAction: _controller.loadInitialData,
      );
    }
    return switch (_controller.viewMode) {
      MatchingViewMode.studio => _buildStudioView(),
      MatchingViewMode.deck => _buildDeckView(),
    };
  }

  Widget _buildDeckView() {
    final match = _controller.currentDeckMatch;
    if (match == null) {
      return MatchFeedEmptyState(
        onAddSkills: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        onConnectGitHub: () =>
            _notify('GitHub connection is not available yet.'),
      );
    }

    return MatchFeedDeckView(
      cardKey: _cardKey,
      match: match,
      nextMatches: _controller.nextDeckMatches,
      canUndo: _controller.canUndo,
      onUndo: _controller.undoLastDeckAction,
      onTap: () => _navigateToProjectDetails(match),
      onAction: (action) => _handleDeckAction(match, action),
      onInfo: () => _showMatchInfo(match),
    );
  }

  List<ExploreDevSyncItem> _buildExploreItems() {
    return [
      ExploreDevSyncItem(
        title: 'AI Studio',
        subtitle: 'Tune your match\nprompts',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AiMatchingStudioScreen(controller: _controller),
          ),
        ),
      ),
      ExploreDevSyncItem(
        title: 'Task board',
        subtitle: 'Plan your next\nsprint',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<bool>(builder: (_) => MatchingProgressScreen()),
        ),
      ),
      ExploreDevSyncItem(
        title: 'Insights',
        subtitle: 'Track contributions',
        onTap: _openAnalytics,
      ),
      ExploreDevSyncItem(
        title: 'Collaboration',
        subtitle: 'Work with your\nteam',
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<bool>(builder: (_) => PromptQualityScreen())),
      ),
    ];
  }

  Widget _buildPageContent() {
    final isEmptyFeed =
        !_controller.isLoading &&
        _controller.errorMessage == null &&
        _controller.viewMode == MatchingViewMode.deck &&
        _controller.currentDeckMatch == null;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MatchFeedAppBar(
              title: isEmptyFeed ? 'Your matches' : 'For you',
              showBookmark: !isEmptyFeed,
              onMenuPressed: () => _notify('DevSync menu opened'),
              onBookmarkPressed: () => _notify('Saved matches'),
              onNotificationsPressed: () => _notify('No new notifications'),
            ),

            Divider(height: 1, color: context.ds.border),
            SizedBox(height: AppSpacing.lg),
            const MatchFeedGreeting(userName: 'Nour'),
            const SizedBox(height: AppSpacing.sm),
            ExploreDevSyncSection(items: _buildExploreItems()),
            const SizedBox(height: AppSpacing.xs),

            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioView() {
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

  void _handleDeckAction(MatchItem match, MatchSwipeAction action) {
    _controller.performDeckAction(match, action);
    final verb = action == MatchSwipeAction.request ? 'requested' : 'skipped';
    _notify('${match.projectName} $verb');
  }

  void _navigateToProjectDetails(MatchItem match) {
    Navigator.of(context).pushNamed(
      AppRoutes.projectDetail,
      arguments: ProjectDetailsArguments(
        match: match,
        currentUserSkills: _controller.profile.declaredSkills,
      ),
    );
  }

  void _notify(String message) {
    final messenger =
        _scaffoldMessengerKey.currentState ??
        ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
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

  void _showMatchInfo(MatchItem match) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ds.surface,
      showDragHandle: true,
      builder: (_) => MatchInfoSheet(match: match),
    );
  }
}
