import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../data/datasources/matching_local_data_source.dart';
import '../../data/datasources/matching_remote_data_source.dart';
import '../../data/repositories/matching_repository_impl.dart';
import '../../domain/entities/match_item.dart';
import '../controllers/matching_controller.dart';
import '../widgets/ai_studio_preferences_card.dart';
import '../widgets/ai_studio_scoring_card.dart';
import '../widgets/ai_studio_suggested_matches_card.dart';
import '../widgets/draggable_match_card.dart';
import '../widgets/explore_devsync_section.dart';
import '../widgets/match_card_deck.dart';
import '../widgets/match_card_skeleton.dart';
import '../widgets/match_feed_app_bar.dart';
import '../widgets/match_feed_greeting.dart';
import 'ai_analytics_screen.dart';
import 'project_details_screen.dart';

/// Screen hosting the AI recommendations and interactive match feed.
///
/// Follows Clean Architecture and SOLID standards by delegating state and
/// business logic to [MatchingController] and separating presentation into
/// focused reusable widgets.
class MatchFeedScreen extends StatefulWidget {
  final bool embedded;
  final MatchingController? controller;
  final MatchingViewMode? initialViewMode;

  const MatchFeedScreen({
    super.key,
    this.embedded = false,
    this.controller,
    this.initialViewMode,
  });

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  late final MatchingController _controller;
  late final bool _ownsController;
  late final TextEditingController _promptTextController;
  final GlobalKey<DraggableMatchCardState> _cardKey =
      GlobalKey<DraggableMatchCardState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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

    final initialMode = widget.initialViewMode ?? MatchingViewMode.deck;
    _controller.setViewMode(initialMode);

    _promptTextController = TextEditingController(
      text: _controller.preferences.prompt,
    );
    _promptTextController.addListener(() {
      _controller.updatePrompt(_promptTextController.text);
    });

    _controller.addListener(_syncPromptController);
  }

  void _syncPromptController() {
    if (_promptTextController.text != _controller.preferences.prompt) {
      _promptTextController.text = _controller.preferences.prompt;
    }
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

  void _navigateToProjectDetails(MatchItem match) {
    Navigator.of(context).pushNamed(
      AppRoutes.projectDetail,
      arguments: ProjectDetailsArguments(
        match: match,
        currentUserSkills: _controller.profile.declaredSkills,
      ),
    );
  }

  void _openAnalytics() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AiAnalyticsScreen(controller: _controller),
      ),
    );
  }

  void _notify(String message) {
    final messenger = _scaffoldMessengerKey.currentState ??
        ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleDeckAction(MatchItem match, MatchSwipeAction action) {
    _controller.performDeckAction(match, action);
    final verb = action == MatchSwipeAction.request ? 'requested' : 'skipped';
    _notify('${match.projectName} $verb');
  }

  void _showMatchInfo(MatchItem match) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ds.surface,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${match.score.round()}% match',
              style: Theme.of(sheetContext).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              match.reason,
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    color: sheetContext.ds.textMuted,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Swipe right to request collaboration or left to skip.',
              style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                    color: sheetContext.ds.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<ExploreDevSyncItem> _buildExploreItems() {
    return [
      ExploreDevSyncItem(
        title: _controller.viewMode == MatchingViewMode.studio
            ? 'Swipe Deck'
            : 'AI Studio',
        subtitle: _controller.viewMode == MatchingViewMode.studio
            ? 'Return to match cards'
            : 'Tune your match\nprompts',
        onTap: () {
          final next = _controller.viewMode == MatchingViewMode.studio
              ? MatchingViewMode.deck
              : MatchingViewMode.studio;
          _controller.setViewMode(next);
          _notify(next == MatchingViewMode.studio
              ? 'Switched to AI Studio'
              : 'Switched to Swipe Deck');
        },
      ),
      ExploreDevSyncItem(
        title: 'Task board',
        subtitle: 'Plan your next\nsprint',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.requests),
      ),
      ExploreDevSyncItem(
        title: 'Insights',
        subtitle: 'Track contributions',
        onTap: _openAnalytics,
      ),
      ExploreDevSyncItem(
        title: 'Collaboration',
        subtitle: 'Work with your\nteam',
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.requests),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final page = SafeArea(
      top: !widget.embedded,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _buildPageContent(),
      ),
    );

    if (widget.embedded) return page;
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(body: page),
    );
  }

  Widget _buildPageContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Column(
          children: [
            // Top App Bar ("DEVSYNC / For you", Menu, Bookmark, Notification)
            MatchFeedAppBar(
              onMenuPressed: () => _notify('DevSync menu opened'),
              onBookmarkPressed: () => _notify('Saved matches'),
              onNotificationsPressed: () => _notify('No new notifications'),
            ),
            // Greeting Section: "Tuesday" / "Good morning, Nour"
            const MatchFeedGreeting(userName: 'Nour'),
            const SizedBox(height: AppSpacing.sm),
            // Explore DevSync Carousel ("Explore DevSync" / "FEATURES")
            ExploreDevSyncSection(items: _buildExploreItems()),
            const SizedBox(height: AppSpacing.xs),
            // Main dynamic content area
            Expanded(
              child: _controller.isLoading
                  ? const Center(child: MatchCardSkeleton())
                  : _controller.errorMessage != null
                      ? DsEmptyState(
                          icon: AppIcons.error,
                          title: 'Something went wrong',
                          message: _controller.errorMessage!,
                          actionLabel: 'Retry',
                          onAction: _controller.loadInitialData,
                        )
                      : _controller.viewMode == MatchingViewMode.studio
                          ? _buildStudioView()
                          : _buildDeckView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudioView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Beta Badge
          Container(
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
          ),
          const SizedBox(height: AppSpacing.md),
          // Preferences Card
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
          // Suggested Matches Card
          AiStudioSuggestedMatchesCard(
            matches: _controller.matches,
            onViewProjectDetails: _navigateToProjectDetails,
          ),
          const SizedBox(height: AppSpacing.md),
          // Scoring Breakdown Card
          AiStudioScoringCard(
            breakdown: _controller.analytics.scoringBreakdown,
            onExploreAnalytics: _openAnalytics,
          ),
        ],
      ),
    );
  }

  Widget _buildDeckView() {
    final match = _controller.currentDeckMatch;
    final total = _controller.matches.length;

    if (match == null) {
      return DsEmptyState(
        icon: AppIcons.feed,
        title: total == 0 ? 'No matches yet' : 'You are all caught up',
        message: total == 0
            ? 'Complete your profile and add skills so we can find projects for you.'
            : 'New project matches will appear here when they are ready.',
        actionLabel: 'Refresh matches',
        onAction: _controller.loadInitialData,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: MatchCardDeck(
                  cardKey: _cardKey,
                  match: match,
                  nextMatches: _controller.nextDeckMatches,
                  onTap: () => _navigateToProjectDetails(match),
                  onAction: (action) => _handleDeckAction(match, action),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _MatchActionBar(
            canUndo: _controller.canUndo,
            onUndo: _controller.undoLastDeckAction,
            onSkip: () => _cardKey.currentState?.complete(MatchSwipeAction.skip),
            onRequest: () =>
                _cardKey.currentState?.complete(MatchSwipeAction.request),
            onInfo: () => _showMatchInfo(match),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _MatchActionBar extends StatelessWidget {
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onSkip;
  final VoidCallback onRequest;
  final VoidCallback onInfo;

  const _MatchActionBar({
    required this.canUndo,
    required this.onUndo,
    required this.onSkip,
    required this.onRequest,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundActionButton(
            tooltip: 'Undo last action',
            icon: AppIcons.undo,
            onPressed: canUndo ? onUndo : null,
          ),
          const SizedBox(width: AppSpacing.md),
          _RoundActionButton(
            tooltip: 'Skip this match',
            icon: AppIcons.close,
            foreground: context.ds.danger,
            onPressed: onSkip,
          ),
          const SizedBox(width: AppSpacing.md),
          _RoundActionButton(
            tooltip: 'Request collaboration',
            icon: AppIcons.heart,
            isPrimary: true,
            onPressed: onRequest,
          ),
          const SizedBox(width: AppSpacing.md),
          _RoundActionButton(
            tooltip: 'How this match was scored',
            icon: AppIcons.info,
            onPressed: onInfo,
          ),
        ],
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? foreground;
  final bool isPrimary;

  const _RoundActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.foreground,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = isPrimary ? AppColors.teal : context.ds.surface;
    final iconColor =
        foreground ?? (isPrimary ? AppColors.onTeal : context.ds.textPrimary);

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: isPrimary ? 64 : 54,
              height: isPrimary ? 64 : 54,
              child: Center(child: DsIcon(icon, color: iconColor)),
            ),
          ),
        ),
      ),
    );
  }
}
