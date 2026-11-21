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
import '../../../../core/widgets/ds_toast.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../shell/presentation/widgets/inbox_badge_builder.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/failures/matching_failures.dart';
import '../cubit/matching_cubit.dart';
import '../widgets/ai_studio_content.dart';
import '../widgets/draggable_match_card.dart';
import '../widgets/empty_matches_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/explore_devsync_section.dart';
import '../widgets/match_card_skeleton.dart';
import '../widgets/match_feed_deck_view.dart';
import '../widgets/match_feed_empty_state.dart';
import '../widgets/match_feed_greeting.dart';
import '../widgets/match_info_sheet.dart';
import 'ai_analytics_screen.dart';
import 'ai_matching_studio_screen.dart';
import 'project_details_screen.dart';

class MatchFeedScreen extends StatefulWidget {
  final MatchingCubit? cubit;
  final MatchingViewMode? initialViewMode;
  final VoidCallback? onMenuPressed;
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
            return InboxBadgeBuilder(
              builder: (context, hasUnreadNotifications, _) {
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
                    onNotifications: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.notifications),
                    notificationBadge: hasUnreadNotifications,
                    actions: [
                      DsIconButton(
                        icon: AppIcons.bookmark,
                        tooltip: 'Liked matches',
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.likedMatches);
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

    // Deck mode first so the first paint never flashes studio.
    final initialMode = widget.initialViewMode ?? MatchingViewMode.deck;
    _cubit.setViewMode(initialMode);
    if (_ownsCubit) _cubit.loadInitialData();
  }

  Widget _buildFeedBody(MatchingState state) {
    final loading =
        state.status == MatchingStatus.loading ||
        state.isLoading ||
        state.isGenerating;

    // Skeleton leaves immediately — no stacked fade/scale that looks like a
    // real match card vanishing into empty.
    if (loading) {
      return KeyedSubtree(
        key: const ValueKey<String>('loading'),
        child: _buildLoadingSkeleton(),
      );
    }

    return AnimatedSwitcher(
      duration: AppAnimations.fast,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey<String>(_contentKey(state)),
        child: _buildContent(state),
      ),
    );
  }

  String _contentKey(MatchingState state) {
    if (state.hasError) return 'error';
    if (state.isEmptyState ||
        state.failure is NoMatchesFailure ||
        state.currentDeckMatch == null) {
      return 'empty';
    }
    return state.viewMode.name;
  }

  Widget _buildContent(MatchingState state) {
    if (state.status == MatchingStatus.loading ||
        state.isLoading ||
        state.isGenerating) {
      return _buildLoadingSkeleton();
    }

    if (state.status == MatchingStatus.empty ||
        state.failure is NoMatchesFailure) {
      return MatchFeedEmptyState(
        hasSkills: state.profile.declaredSkills.isNotEmpty,
        hasReviewedAll: false,
        onAddSkills: _openMatchingProfile,
        onConnectGitHub: _openMatchingProfile,
      );
    }

    if (state.status == MatchingStatus.failure || state.failure != null) {
      final failure = state.failure ?? UnknownFailure(state.errorMessage);
      return ErrorStateWidget(failure: failure, onRetry: _cubit.retry);
    }

    final error = state.errorMessage;
    if (error != null) {
      return DsEmptyState(
        icon: AppIcons.error,
        title: 'Something went wrong',
        message: error,
        actionLabel: 'Retry',
        onAction: _cubit.retry,
      );
    }

    return switch (state.viewMode) {
      MatchingViewMode.studio => _buildStudioView(state),
      MatchingViewMode.deck => _buildDeckView(state),
    };
  }

  Widget _buildLoadingSkeleton() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          MatchCardSkeleton(),
          Spacer(),
          MatchActionBarSkeleton(),
          SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildDeckView(MatchingState state) {
    final match = state.currentDeckMatch;
    if (match == null) {
      if (state.matches.isEmpty && !state.hasError) {
        return EmptyMatchesWidget(onRefresh: _cubit.retry);
      }

      return MatchFeedEmptyState(
        hasSkills: state.profile.declaredSkills.isNotEmpty,
        hasReviewedAll: state.matches.isNotEmpty,
        onAddSkills: _openMatchingProfile,
        onConnectGitHub: _openMatchingProfile,
      );
    }

    return AbsorbPointer(
      absorbing: state.isSaving,
      child: MatchFeedDeckView(
        cardKey: _cardKey,
        match: match,
        nextMatches: state.nextDeckMatches,
        canUndo: state.canUndo,
        onUndo: _undo,
        onTap: () => _navigateToProjectDetails(match, state),
        onAction: (action) => _handleDeckAction(match, action),
        onInfo: () => _showMatchInfo(match),
      ),
    );
  }

  List<ExploreDevSyncItem> _buildExploreItems() {
    return [
      ExploreDevSyncItem(
        title: 'AI Studio',
        subtitle: 'Tune your match\nprompts',
        icon: AppIcons.sparkle,
        onTap: () => Navigator.of(context).push(
          DsFadePageRoute<void>(
            builder: (_) => AiMatchingStudioScreen(cubit: _cubit),
          ),
        ),
      ),
      ExploreDevSyncItem(
        title: 'Insights',
        subtitle: 'Review your\nmatch results',
        icon: AppIcons.chart,
        onTap: _openAnalytics,
      ),
      ExploreDevSyncItem(
        title: 'Prompt guide',
        subtitle: 'Improve your\npreferences',
        icon: AppIcons.zap,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.promptQuality),
      ),
    ];
  }

  void _openRefreshMatches() {
    Navigator.of(context).push(
      DsFadePageRoute<bool>(
        builder: (_) => MatchingProgressScreen(cubit: _cubit),
      ),
    );
  }

  String _greetingName(BuildContext context) {
    AppUser? user;
    try {
      final auth =
          (context.read<AuthCubit?>() ??
                  (getIt.isRegistered<AuthCubit>() ? getIt<AuthCubit>() : null))
              ?.state;
      if (auth is AuthAuthenticated) {
        user = auth.user;
      } else if (auth is AuthNeedsVerification) {
        user = auth.user;
      }
    } catch (_) {}

    final display = user?.displayName?.trim() ?? '';
    if (display.isNotEmpty) {
      return display.split(RegExp(r'\s+')).first;
    }

    final email = user?.email?.trim() ?? '';
    if (email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) return local;
    }

    return 'there';
  }

  void _openMatchingProfile() {
    if (widget.onOpenProfile != null) {
      widget.onOpenProfile!();
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.connectGithub);
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
                Builder(
                  builder: (context) {
                    AuthCubit? authCubit;
                    try {
                      authCubit = context.read<AuthCubit>();
                    } catch (_) {
                      if (getIt.isRegistered<AuthCubit>()) {
                        authCubit = getIt<AuthCubit>();
                      }
                    }
                    if (authCubit == null) {
                      return MatchFeedGreeting(
                        userName: state.profileName ?? 'there',
                      );
                    }
                    return BlocBuilder<AuthCubit, AuthState>(
                      bloc: authCubit,
                      buildWhen: (prev, next) =>
                          prev.runtimeType != next.runtimeType ||
                          (prev is AuthAuthenticated &&
                              next is AuthAuthenticated &&
                              prev.user.displayName != next.user.displayName),
                      builder: (context, _) =>
                          MatchFeedGreeting(userName: _greetingName(context)),
                    );
                  },
                ),
                ExploreDevSyncSection(
                  items: _buildExploreItems(),
                  trailing: DsIconButton(
                    icon: AppIcons.refresh,
                    tooltip: 'Refresh matches',
                    onPressed: _openRefreshMatches,
                  ),
                ),
              ],
            ),
            Expanded(child: _buildFeedBody(state)),
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
      availableTags: state.profile.declaredSkills,
      isGenerating: state.isGenerating || state.isLoading,
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
    final error = state.errorMessage;
    if (error != null) {
      _notify(error, tone: DsToastTone.error);
    } else {
      _notify(
        '${state.matches.length} matches generated',
        tone: DsToastTone.success,
      );
    }
  }

  Future<void> _handleDeckAction(
    MatchItem match,
    MatchSwipeAction action,
  ) async {
    final success = await _cubit.performDeckAction(match, action);
    if (!mounted) return;
    if (!success) {
      _cardKey.currentState?.restore();
      _notify(
        _cubit.state.actionErrorMessage ??
            'Could not save this action. Try again.',
        tone: DsToastTone.error,
      );
      return;
    }
    final verb = action == MatchSwipeAction.request ? 'saved' : 'skipped';
    _notify('${match.projectName} $verb', tone: DsToastTone.success);
  }

  Future<void> _undo() async {
    await _cubit.undoLastDeckAction();
    if (!mounted) return;
    final error = _cubit.state.actionErrorMessage;
    if (error != null) _notify(error, tone: DsToastTone.error);
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

  void _notify(String message, {DsToastTone tone = DsToastTone.info}) {
    showDsToast(context, message, tone: tone);
  }

  Future<void> _openAnalytics() async {
    final refreshNeeded = await Navigator.of(context).push<bool>(
      DsFadePageRoute<bool>(builder: (_) => AiAnalyticsScreen(cubit: _cubit)),
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
