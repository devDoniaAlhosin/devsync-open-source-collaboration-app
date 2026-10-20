import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_avatar.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_score_meter.dart';
import '../../domain/entities/match_item.dart';
import 'draggable_match_card.dart';

class MatchCardDeck extends StatelessWidget {
  const MatchCardDeck({
    super.key,
    required this.match,
    required this.nextMatches,
    required this.onAction,
    this.onTap,
    this.cardKey,
  });

  final MatchItem match;
  final List<MatchItem> nextMatches;
  final ValueChanged<MatchSwipeAction> onAction;
  final VoidCallback? onTap;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final previewMatches = nextMatches.take(2).toList().reversed.toList();
    return Padding(
      padding: EdgeInsets.only(bottom: previewMatches.isEmpty ? 0 : 28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var index = 0; index < previewMatches.length; index++)
            _DeckPreview(
              match: previewMatches[index],
              depth: previewMatches.length - index,
            ),
          DraggableMatchCard(
            key: cardKey,
            match: match,
            onAction: onAction,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _DeckPreview extends StatelessWidget {
  const _DeckPreview({required this.match, required this.depth});

  final MatchItem match;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final offset = depth * 12.0;
    final scale = 1 - depth * .035;
    return Positioned.fill(
      top: offset,
      bottom: -offset,
      child: IgnorePointer(
        child: Opacity(
          opacity: 1 - depth * .15,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: SizedBox.expand(
              child: DsCard(
                borderRadius: AppSpacing.radiusMatch,
                child: Row(
                  children: [
                    DsProjectAvatar(label: _initialsFor(match.projectName)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        match.projectName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    DsScoreRing(score: match.score, size: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _initialsFor(String projectName) => projectName
      .split(RegExp(r'[/\s-]'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join();
}
