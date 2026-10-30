import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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

  static const int _maxPeekLayers = 2;

  @override
  Widget build(BuildContext context) {
    // Prefer real upcoming matches; pad with blank silhouettes so the
    // stack affordance stays visible whenever more cards exist.
    final upcoming = nextMatches.take(_maxPeekLayers).toList();
    final peekCount = upcoming.isEmpty ? 0 : _maxPeekLayers;
    final bottomPad = peekCount == 0 ? 0.0 : peekCount * _DeckPeek.offsetStep + 4;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPad),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var depth = peekCount; depth >= 1; depth--)
            _DeckPeek(
              depth: depth,
              match: depth <= upcoming.length ? upcoming[depth - 1] : null,
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

/// Full-size card silhouette behind the active match so the deck reads as
/// a swipeable stack (edges peek below / beside the front card).
class _DeckPeek extends StatelessWidget {
  const _DeckPeek({required this.depth, this.match});

  static const double offsetStep = 14;

  final int depth;
  final MatchItem? match;

  @override
  Widget build(BuildContext context) {
    final palette = context.ds;
    final offset = depth * offsetStep;
    final scale = 1 - depth * .045;
    final inset = depth * 10.0;
    final peekMatch = match;

    return Positioned(
      left: inset,
      right: inset,
      top: offset,
      bottom: -offset,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - depth * .22).clamp(0.45, 1),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMatch),
                border: Border.all(color: palette.border),
                boxShadow: [
                  BoxShadow(
                    color: palette.textPrimary.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: peekMatch == null
                  ? const SizedBox.expand()
                  : Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.cardPadding,
                          AppSpacing.cardPadding,
                          AppSpacing.cardPadding,
                          0,
                        ),
                        child: Text(
                          peekMatch.projectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: palette.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
