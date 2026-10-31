import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/matching_progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/di/injection.dart';
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
import '../cubit/matching_cubit.dart';
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
class MatchFeedScreen extends StatefulWidget {
  final MatchingCubit? cubit;
  final MatchingViewMode? initialViewMode;
  final VoidCallback? onMenuPressed;

  /// Switches the host shell to the Profile tab (keeps the drawer).
  final VoidCallback? onOpenProfile;

  const MatchFeedScreen({
    super.key,
    this.cubit,
    this.initialViewMode,
    this.onMenuPressed,
    this.onOpenProfile,
  });

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  late final MatchingCubit _cubit;
  late final bool _ownsCubit;
  final GlobalKey<DraggableMatchCardState> _cardKey =
      GlobalKey<DraggableMatchCardState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: BlocBuilder<MatchingCubit, MatchingState>(
          builder: (context, state) {
            final isEmptyFeed =
                !state.isLoading &&
                state.errorMessage == null &&
                state.viewMode == MatchingViewMode.deck &&
                state.currentDeckMatch == null;
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
                child: DsPageFade(child: _buildPageContent(state)),
              ),
            );
          },
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

    final initialMode = widget.initialViewMode ?? MatchingViewMode.deck;
    _cubit.setViewMode(initialMode);
  }

  Widget _buildContent(MatchingState state) {
    if (state.isLoading) return _buildLoadingSkeleton();
    final error = state.errorMessage;
    if (error != null) {
      return DsEmptyState(
        icon: AppIcons.error,
        title: 'Something went wrong',
        message: error,
        actionLabel: 'Retry',
        onAction: _cubit.loadInitialData,
      );
    }
    return switch (state.viewMode) {
      MatchingViewMode.studio => _buildStudioView(state),
      MatchingViewMode.deck => _buildDeckView(state),
    };
  }

  Widget _buildLoadingSkeleton() {
    return const Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: MatchCardSkeleton(),
      ),
    );
  }

  Widget _buildDeckView(MatchingState state) {
    final match = state.currentDeckMatch;
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
      nextMatches: state.nextDeckMatches,
      canUndo: state.canUndo,
      onUndo: _cubit.undoLastDeckAction,
      onTap: () => _navigateToProjectDetails(match, state),
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
            builder: (_) => AiMatchingStudioScreen(cubit: _cubit),
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

  Widget _buildPageContent(MatchingState state) {
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
                    state.isLoading
                        ? 'loading'
                        : state.errorMessage != null
                        ? 'error'
                        : state.viewMode.name,
                  ),
                  child: _buildContent(state),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioView(MatchingState state) {
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

  void _handleDeckAction(MatchItem match, MatchSwipeAction action) {
    _cubit.performDeckAction(match, action);
    final verb = action == MatchSwipeAction.request ? 'requested' : 'skipped';
    _notify('${match.projectName} $verb');
  }

  void _navigateToProjectDetails(MatchItem match, MatchingState state) {
    Navigator.of(context).pushNamed(
      AppRoutes.projectDetail,
      arguments: ProjectDetailsArguments(
        match: match,
        currentUserSkills: state.profile.declaredSkills,
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
        builder: (_) => AiAnalyticsScreen(cubit: _cubit),
      ),
    );
    if (refreshNeeded == true && mounted) {
      await _cubit.loadInitialData();
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
