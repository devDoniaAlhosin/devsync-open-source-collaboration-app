import 'package:material_ui/material_ui.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../data/datasources/matching_local_data_source.dart';
import '../../data/datasources/matching_remote_data_source.dart';
import '../../data/repositories/matching_repository_impl.dart';
import '../../domain/entities/match_item.dart';
import '../../domain/entities/user_profile.dart';
import '../widgets/draggable_match_card.dart';
import '../widgets/match_card_deck.dart';
import '../widgets/match_card_skeleton.dart';
import 'project_details_screen.dart';

class MatchFeedScreen extends StatefulWidget {
  final bool embedded;

  const MatchFeedScreen({super.key, this.embedded = false});

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _FallbackNotice extends StatelessWidget {
  const _FallbackNotice();

  @override
  Widget build(BuildContext context) {
    return DsCard(
      tone: DsCardTone.inset,
      borderRadius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: const Row(
        children: [
          DsIcon(AppIcons.info, size: 18, color: AppColors.teal),
          SizedBox(width: AppSpacing.sm),
          Expanded(child: _FallbackText()),
        ],
      ),
    );
  }
}

class _FallbackText extends StatelessWidget {
  const _FallbackText();

  @override
  Widget build(BuildContext context) => Text(
    'AI matching is temporarily unavailable. Showing skills-based results.',
    style: Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
  );
}

class _FeedHeader extends StatelessWidget {
  final int current;

  final int total;
  const _FeedHeader({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final visiblePosition = total == 0 ? 0 : (current + 1).clamp(1, total);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your next match',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'AI-ranked for your skills and GitHub activity',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
              ),
            ],
          ),
        ),
        if (total > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: context.ds.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(color: context.ds.border),
            ),
            child: Text(
              '$visiblePosition / $total',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _MatchAction {
  final int index;

  final MatchSwipeAction action;
  const _MatchAction({required this.index, required this.action});
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

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  static const _profile = UserProfile(
    uid: 'demo-user',
    declaredSkills: ['Flutter', 'Dart', 'Firebase'],
    githubLanguages: {'Dart': 60, 'Python': 20, 'JavaScript': 10},
    publicRepoCount: 12,
    totalContributions: 340,
    bio: 'Mobile developer interested in open source.',
  );

  late final MatchingRepositoryImpl _repository;
  final GlobalKey<DraggableMatchCardState> _cardKey =
      GlobalKey<DraggableMatchCardState>();
  final List<_MatchAction> _history = [];

  List<MatchItem> _matches = [];
  int _currentMatchIndex = 0;
  bool _isLoading = true;
  bool _hasFallback = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final page = SafeArea(top: !widget.embedded, child: _buildPage());

    if (widget.embedded) return page;
    return Scaffold(body: page);
  }

  @override
  void initState() {
    super.initState();
    _repository = MatchingRepositoryImpl(
      remoteDataSource: MockMatchingRemoteDataSource(),
      localDataSource: InMemoryMatchingLocalDataSource(),
    );
    _loadMatches();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 460),
          child: MatchCardSkeleton(),
        ),
      );
    }

    if (_errorMessage != null) {
      return DsEmptyState(
        icon: AppIcons.error,
        title: 'Something went wrong',
        message: _errorMessage!,
        actionLabel: 'Retry',
        onAction: _loadMatches,
      );
    }

    if (_matches.isEmpty || _currentMatchIndex >= _matches.length) {
      return DsEmptyState(
        icon: AppIcons.feed,
        title: _matches.isEmpty ? 'No matches yet' : 'You are all caught up',
        message: _matches.isEmpty
            ? 'Complete your profile and add skills so we can find projects for you.'
            : 'New project matches will appear here when they are ready.',
        actionLabel: 'Refresh matches',
        onAction: _loadMatches,
      );
    }

    final match = _matches[_currentMatchIndex];
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: MatchCardDeck(
                      cardKey: _cardKey,
                      match: match,
                      nextMatches: _matches
                          .skip(_currentMatchIndex + 1)
                          .take(2)
                          .toList(),
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.projectDetail,
                        arguments: ProjectDetailsArguments(
                          match: match,
                          currentUserSkills: _profile.declaredSkills,
                        ),
                      ),
                      onAction: (action) => _handleAction(match, action),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _MatchActionBar(
          canUndo: _history.isNotEmpty,
          onUndo: _undoLastAction,
          onSkip: () => _cardKey.currentState?.complete(MatchSwipeAction.skip),
          onRequest: () =>
              _cardKey.currentState?.complete(MatchSwipeAction.request),
          onInfo: () => _showMatchInfo(match),
        ),
        const SizedBox(height: AppSpacing.lg),
        DsButton(
          label: 'Open collaboration workspace',
          icon: AppIcons.forward,
          compact: true,
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.requests),
        ),
      ],
    );
  }

  Widget _buildPage() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FeedHeader(current: _currentMatchIndex, total: _matches.length),
          if (_hasFallback) ...[
            const SizedBox(height: AppSpacing.md),
            const _FallbackNotice(),
          ],
          const SizedBox(height: AppSpacing.lg),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  void _handleAction(MatchItem match, MatchSwipeAction action) {
    if (_currentMatchIndex >= _matches.length ||
        _matches[_currentMatchIndex].projectId != match.projectId) {
      return;
    }

    setState(() {
      _history.add(_MatchAction(index: _currentMatchIndex, action: action));
      _currentMatchIndex++;
    });

    final verb = action == MatchSwipeAction.request ? 'requested' : 'skipped';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${match.projectName} $verb')));
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _repository.getRankedMatches(_profile);

      if (!mounted) return;
      setState(() {
        _matches = results;
        _currentMatchIndex = 0;
        _history.clear();
        _hasFallback = results.any((match) => match.isFallback);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load matches. Please try again.';
      });
    }
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
              style: Theme.of(sheetContext).textTheme.headlineSmall,
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
              style: Theme.of(
                sheetContext,
              ).textTheme.bodySmall?.copyWith(color: sheetContext.ds.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _undoLastAction() {
    if (_history.isEmpty) return;
    final lastAction = _history.removeLast();
    setState(() => _currentMatchIndex = lastAction.index);
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
      opacity: enabled ? 1 : .4,
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
