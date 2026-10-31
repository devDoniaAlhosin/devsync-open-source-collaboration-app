import 'package:flutter/material.dart';

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
import '../../../projects/domain/entities/project.dart';
import '../../../requests/presentation/collaboration_request_flow.dart';
import '../../domain/entities/match_item.dart';
import '../liked_matches_store.dart';
import 'project_details_screen.dart';

/// Prototype **6b. Liked matches** — hearts from the feed land here.
class LikedMatchesScreen extends StatelessWidget {
  const LikedMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final liked = LikedMatchesStore.instance.items;
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: DsAppBar(
        title: 'Liked',
        eyebrow: 'WORKSPACE',
        showBack: true,
        onBack: () => Navigator.of(context).maybePop(),
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
        notificationBadge: true,
      ),
      body: DsPageFade(
        child: liked.isEmpty
            ? const Center(
                child: DsEmptyState(
                  icon: AppIcons.bookmark,
                  title: 'No liked matches yet',
                  message: 'Like a card on Matches and it will show up here.',
                ),
              )
            : ListView(
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
                    eyebrow: '${liked.length} saved',
                    body:
                        'Heart on the feed saves here. Same feedback Emad '
                        'uses to tune ranking — not a second Favorites product.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DsStagger(
                    spacing: AppSpacing.md,
                    children: [
                      for (final match in liked)
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
                              maintainerName: 'Karim',
                              initials: initialsFromTitle(match.projectName),
                              matchPercent: match.score.round(),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Liked matches help ranking — they are not a separate '
                    'Favorites product.',
                    style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                  ),
                ],
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
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      match.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: ds.textMuted,
                      ),
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
