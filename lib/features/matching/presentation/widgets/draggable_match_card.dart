import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_avatar.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_chip.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_score_meter.dart';
import '../../domain/entities/match_item.dart';

/// A Tinder-style, horizontally draggable project match card.
///
/// The card deliberately has button-free content so a drag cannot conflict
/// with controls inside the card. The screen provides labelled action buttons
/// as an accessible alternative to swiping.
class DraggableMatchCard extends StatefulWidget {
  final MatchItem match;

  final ValueChanged<MatchSwipeAction> onAction;
  const DraggableMatchCard({
    super.key,
    required this.match,
    required this.onAction,
  });

  @override
  DraggableMatchCardState createState() => DraggableMatchCardState();
}

class DraggableMatchCardState extends State<DraggableMatchCard> {
  static const double _dismissDistance = 104;
  static const double _dismissVelocity = 760;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset.dx.abs() / _dismissDistance).clamp(0.0, 1.0);
    final isRequest = _dragOffset.dx > 0;
    final rotation = _dragOffset.dx / 1700;

    return Semantics(
      label:
          '${widget.match.projectName}. Swipe right to request collaboration, or left to skip.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        onPanCancel: _restore,
        child: AnimatedContainer(
          duration: _isDragging ? Duration.zero : AppAnimations.normal,
          curve: AppAnimations.emphasized,
          transform: Matrix4.identity()
            ..translateByDouble(_dragOffset.dx, _dragOffset.dy, 0, 1)
            ..rotateZ(rotation),
          transformAlignment: Alignment.center,
          child: Stack(
            children: [
              DsCard(
                borderRadius: AppSpacing.radiusMatch,
                child: _MatchCardContent(match: widget.match),
              ),
              if (_dragOffset.dx != 0)
                Positioned(
                  top: AppSpacing.lg,
                  left: isRequest ? null : AppSpacing.lg,
                  right: isRequest ? AppSpacing.lg : null,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: progress,
                      child: _SwipeLabel(
                        action: isRequest
                            ? MatchSwipeAction.request
                            : MatchSwipeAction.skip,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Runs the same exit animation used for a swipe. This is used by the
  /// labelled action controls beneath the card.
  Future<void> complete(MatchSwipeAction action) async {
    if (_isCompleting) return;

    setState(() {
      _isCompleting = true;
      _isDragging = false;
      _dragOffset = Offset(
        action == MatchSwipeAction.request ? 720 : -720,
        _dragOffset.dy,
      );
    });

    await Future<void>.delayed(AppAnimations.normal);
    if (!mounted) return;
    widget.onAction(action);
  }

  @override
  void didUpdateWidget(covariant DraggableMatchCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match.projectId != widget.match.projectId) {
      _dragOffset = Offset.zero;
      _isDragging = false;
      _isCompleting = false;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dx;
    final distance = _dragOffset.dx;
    final shouldDismiss =
        distance.abs() >= _dismissDistance ||
        velocity.abs() >= _dismissVelocity;

    if (!shouldDismiss) {
      _restore();
      return;
    }

    final action = distance == 0
        ? (velocity.isNegative
              ? MatchSwipeAction.skip
              : MatchSwipeAction.request)
        : (distance.isNegative
              ? MatchSwipeAction.skip
              : MatchSwipeAction.request);
    complete(action);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCompleting) return;

    setState(() {
      _isDragging = true;
      _dragOffset = Offset(
        (_dragOffset.dx + details.delta.dx).clamp(-260.0, 260.0),
        (_dragOffset.dy + details.delta.dy * .18).clamp(-28.0, 28.0),
      );
    });
  }

  void _restore() {
    if (_isCompleting) return;
    setState(() {
      _isDragging = false;
      _dragOffset = Offset.zero;
    });
  }
}

/// The two feedback actions available on a match card.
///
/// A request maps to a right swipe and a skip maps to a left swipe. Keeping
/// this type in the presentation layer lets the feedback owner connect the
/// same actions to Firestore without changing the drag interaction.
enum MatchSwipeAction { skip, request }

class _MatchCardContent extends StatelessWidget {
  final MatchItem match;

  const _MatchCardContent({required this.match});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final skills = match.neededSkills.take(3).toList();
    final metrics = skills.isEmpty
        ? const ['Skill fit', 'Activity', 'Interest']
        : skills;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DsProjectAvatar(label: _initialsFor(match.projectName)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    match.projectName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    match.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.ds.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DsScoreRing(score: match.score, size: 58),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.darkCanvas,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  DsIcon(AppIcons.sparkle, size: 15, color: AppColors.teal),
                  SizedBox(width: 6),
                  _MatchReasonHeading(),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                match.reason,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: context.ds.textPrimary,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < metrics.length; index++) ...[
          _MatchMetric(
            label: metrics[index],
            score: (match.score - index * 9).clamp(38, 100).toDouble(),
          ),
          if (index < metrics.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final skill in skills)
              DsChip(label: skill, variant: DsChipVariant.muted),
          ],
        ),
      ],
    );
  }

  String _initialsFor(String projectName) => projectName
      .split(RegExp(r'[/\s-]'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join();
}

class _MatchMetric extends StatelessWidget {
  final String label;

  final double score;
  const _MatchMetric({required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.ds.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: DsScoreMeter(score: score, height: 6, animate: false)),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 24,
          child: Text(
            score.round().toString(),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: context.ds.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchReasonHeading extends StatelessWidget {
  const _MatchReasonHeading();

  @override
  Widget build(BuildContext context) => Text(
    'Why this fits',
    style: Theme.of(context).textTheme.labelMedium?.copyWith(
      color: AppColors.teal,
      fontWeight: FontWeight.w800,
    ),
  );
}

class _SwipeLabel extends StatelessWidget {
  final MatchSwipeAction action;

  const _SwipeLabel({required this.action});

  @override
  Widget build(BuildContext context) {
    final isRequest = action == MatchSwipeAction.request;
    final color = isRequest ? AppColors.teal : context.ds.danger;

    return Transform.rotate(
      angle: isRequest ? -.13 : .13,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: color, width: 2),
        ),
        child: Text(
          isRequest ? 'REQUEST' : 'SKIP',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
