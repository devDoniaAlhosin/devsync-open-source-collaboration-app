import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/matching_progress_screen.dart';
import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/navigation/open_host_drawer.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_fade_switch.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../../../../core/widgets/ds_page_fade.dart';
import '../../../../core/widgets/ds_staggered_entrance.dart';
import '../../domain/entities/match_item.dart';
import '../../matching_dependencies.dart';
import '../controllers/matching_controller.dart';
import '../widgets/ai_studio_content.dart';
import '../widgets/draggable_match_card.dart';
import '../widgets/explore_devsync_section.dart';
import '../widgets/match_card_skeleton.dart';
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
  final VoidCallback? onMenuPressed;

  /// Switches the host shell to the Profile tab (keeps the drawer).
  final VoidCallback? onOpenProfile;

  const MatchFeedScreen({
    super.key,
    this.controller,
    this.initialViewMode,
    this.onMenuPressed,
    this.onOpenProfile,
  });

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
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final isEmptyFeed =
              !_controller.isLoading &&
              _controller.errorMessage == null &&
              _controller.viewMode == MatchingViewMode.deck &&
              _controller.currentDeckMatch == null;
          return Scaffold(
            appBar: DsAppBar(
              title: isEmptyFeed ? 'Your matches' : 'For you',
              eyebrow: 'DEVSYNC',
              showMenu: true,
              onMenu: () {
                if (widget.onMenuPressed != null) {
                  widget.onMenuPressed!();
                  return;
                }
                openHostDrawer(context);
              },
              onNotifications: () =>
                  Navigator.of(context).pushNamed(AppRoutes.notifications),
              notificationBadge: true,
              actions: [
                DsIconButton(
                  icon: AppIcons.bookmark,
                  tooltip: 'Liked matches',
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.likedMatches);
                  },
                ),
              ],
            ),
            body: SafeArea(
              top: false,
              child: DsPageFade(child: _buildPageContent()),
            ),
          );
        },
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

    final initialMode = widget.initialViewMode ?? MatchingViewMode.deck;
    _controller.setViewMode(initialMode);
  }

  Widget _buildContent() {
    if (_controller.isLoading) return _buildLoadingSkeleton();
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

  /// Top-aligned content placeholder while matches load.
  Widget _buildLoadingSkeleton() {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: MatchCardSkeleton(),
      ),
    );
  }

  Widget _buildDeckView() {
    final match = _controller.currentDeckMatch;
    if (match == null) {
      return MatchFeedEmptyState(
        onAddSkills: () {
          if (widget.onOpenProfile != null) {
            widget.onOpenProfile!();
            return;
          }
          Navigator.of(context).pushNamed(AppRoutes.profile);
        },
        onConnectGitHub: () =>
            Navigator.of(context).pushNamed(AppRoutes.connectGithub),
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
          DsFadePageRoute<void>(
            builder: (_) => AiMatchingStudioScreen(controller: _controller),
          ),
        ),
      ),
      ExploreDevSyncItem(
        title: 'Task board',
        subtitle: 'Plan your next\nsprint',
        onTap: () => Navigator.of(context).push(
          DsFadePageRoute<bool>(builder: (_) => MatchingProgressScreen()),
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
        ).push(DsFadePageRoute<bool>(builder: (_) => PromptQualityScreen())),
      ),
    ];
  }

  Widget _buildPageContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            DsStagger(
              mainAxisSize: MainAxisSize.min,
              spacing: AppSpacing.sm,
              children: [
                const MatchFeedGreeting(userName: 'Nour'),
                ExploreDevSyncSection(items: _buildExploreItems()),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppAnimations.slow,
                switchInCurve: AppAnimations.emphasized,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: AppAnimations.emphasized,
                  );
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(fade),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.985, end: 1).animate(fade),
                        child: child,
                      ),
                    ),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      ?currentChild,
                    ],
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<String>(
                    _controller.isLoading
                        ? 'loading'
                        : _controller.errorMessage != null
                        ? 'error'
                        : _controller.viewMode.name,
                  ),
                  child: _buildContent(),
                ),
              ),
            ),
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
      DsFadePageRoute<bool>(
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
