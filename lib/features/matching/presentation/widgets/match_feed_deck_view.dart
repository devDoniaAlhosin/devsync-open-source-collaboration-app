import 'package:material_ui/material_ui.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../domain/entities/match_item.dart';
import 'draggable_match_card.dart';
import 'match_card_deck.dart';

class MatchFeedDeckView extends StatelessWidget {
  const MatchFeedDeckView({
    super.key,
    required this.cardKey,
    required this.match,
    required this.nextMatches,
    required this.canUndo,
    required this.onUndo,
    required this.onTap,
    required this.onAction,
    required this.onInfo,
  });
  final GlobalKey<DraggableMatchCardState> cardKey;
  final MatchItem match;
  final List<MatchItem> nextMatches;
  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onTap;
  final ValueChanged<MatchSwipeAction> onAction;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SingleChildScrollView(
                  child: MatchCardDeck(
                    cardKey: cardKey,
                    match: match,
                    nextMatches: nextMatches,
                    onTap: onTap,
                    onAction: onAction,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _MatchActionBar(
            canUndo: canUndo,
            onUndo: onUndo,
            onSkip: () => cardKey.currentState?.complete(MatchSwipeAction.skip),
            onRequest: () =>
                cardKey.currentState?.complete(MatchSwipeAction.request),
            onInfo: onInfo,
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
