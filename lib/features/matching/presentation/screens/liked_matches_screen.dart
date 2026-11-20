import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_avatar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_chip.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../../core/widgets/ds_fade_switch.dart';
import '../../../../core/widgets/ds_page_fade.dart';
import '../../../../core/widgets/ds_page_header.dart';
import '../../../../core/widgets/ds_score_meter.dart';
import '../../../../core/widgets/ds_staggered_entrance.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../requests/presentation/collaboration_request_flow.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/match_item.dart';
import '../../data/datasources/liked_matches_local_data_source.dart';
import 'project_details_screen.dart';

class LikedMatchesScreen extends StatefulWidget {
  const LikedMatchesScreen({super.key, this.dataSource});

  final LikedMatchesLocalDataSource? dataSource;

  @override
  State<LikedMatchesScreen> createState() => _LikedMatchesScreenState();
}

class _LikedMatchesScreenState extends State<LikedMatchesScreen> {
  late final LikedMatchesLocalDataSource _dataSource;
  List<MatchItem> _likedMatches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dataSource = widget.dataSource ?? getIt<LikedMatchesLocalDataSource>();
    _loadLikedMatches();
  }

  String _currentUserName(BuildContext context) {
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

    final displayName = user?.displayName?.trim() ?? '';
    if (displayName.isNotEmpty) {
      return displayName.split(RegExp(r'\s+')).first;
    }

    final email = user?.email?.trim() ?? '';
    if (email.contains('@')) {
      final localPart = email.split('@').first.trim();
      if (localPart.isNotEmpty) return localPart;
    }

    return 'You';
  }

  Future<void> _loadLikedMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final matches = await _dataSource.getLikedMatches();
      if (!mounted) return;
      setState(() {
        _likedMatches = matches;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error =
            'Could not load your saved matches. Check your connection and sign-in, then retry.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        appBar: DsAppBar(
          title: 'Liked',
          eyebrow: 'WORKSPACE',
          showBack: true,
          onBack: () => Navigator.of(context).maybePop(),
          onNotifications: () {
            Navigator.of(context).pushNamed(AppRoutes.notifications);
          },
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.ds.background,
      appBar: DsAppBar(
        title: 'Liked',
        eyebrow: 'WORKSPACE',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
      ),
      body: DsPageFade(
        child: _error != null
            ? DsEmptyState(
                icon: AppIcons.error,
                title: 'Could not load saved matches',
                message: _error,
                actionLabel: 'Retry',
                onAction: _loadLikedMatches,
              )
            : _likedMatches.isEmpty
            ? const Center(
                child: DsEmptyState(
                  icon: AppIcons.bookmark,
                  title: 'No liked matches yet',
                  message: 'Like a card on Matches and it will show up here.',
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadLikedMatches,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.sm,
                    AppSpacing.screenPadding,
                    AppSpacing.xxxl,
                  ),
                  children: [
                    DsPageHeader(
                      style: DsPageHeaderStyle.page,
                      title: 'Liked matches',
                      eyebrow: '${_currentUserName(context)} · like/skip',
                      body:
                          'Heart on the feed saves here. Your feedback helps tune ranking — not a second Favorites product.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DsStagger(
                      spacing: AppSpacing.md,
                      children: [
                        for (final match in _likedMatches)
                          _LikedMatchCard(
                            match: match,
                            onView: () {
                              Navigator.of(context).push(
                                DsFadePageRoute<void>(
                                  builder: (_) => ProjectDetailsScreen(
                                    arguments: ProjectDetailsArguments(
                                      match: match,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onRequest: () {
                              presentCollaborationRequestFlow(
                                context,
                                projectName: match.projectName,
                                maintainerName: 'Project maintainer',
                                initials: initialsFromTitle(match.projectName),
                                projectId: match.projectId,
                                ownerId: match.maintainerId,
                                matchPercent: match.score.round(),
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Saved matches stay linked to their project details and '
                      'recommendation score.',
                      style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LikedMatchCard extends StatelessWidget {
  const _LikedMatchCard({
    required this.match,
    required this.onView,
    required this.onRequest,
  });

  final MatchItem match;
  final VoidCallback onView;
  final VoidCallback onRequest;

  String get _initials {
    final parts = match.projectName
        .split(RegExp(r'[/\s-]'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return parts.isEmpty ? '?' : parts;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsProjectAvatar(label: _initials),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.projectName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      match.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                    ),
                  ],
                ),
              ),
              DsScoreRing(score: match.score, size: 52),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final skill in match.neededSkills.take(4))
                DsChip(label: skill),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              TextButton(
                onPressed: onView,
                child: Text(
                  'View',
                  style: textTheme.labelLarge?.copyWith(
                    color: ds.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 120,
                child: DsButton(
                  label: 'Request',
                  onPressed: onRequest,
                  compact: true,
                  expanded: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
