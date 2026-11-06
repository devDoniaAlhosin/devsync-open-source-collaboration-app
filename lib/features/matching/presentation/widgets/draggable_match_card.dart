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

class DraggableMatchCard extends StatefulWidget {
  const DraggableMatchCard({
    super.key,
    required this.match,
    required this.onAction,
    this.onTap,
  });

  final MatchItem match;
  final ValueChanged<MatchSwipeAction> onAction;
  final VoidCallback? onTap;

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
      button: widget.onTap != null,
      label:
          '${widget.match.projectName}. Swipe right to save this match, or left to skip.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
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

  /// A failed save keeps the same card available for another attempt.
  void restore() {
    if (!mounted) return;
    setState(() {
      _dragOffset = Offset.zero;
      _isDragging = false;
      _isCompleting = false;
    });
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

enum MatchSwipeAction { skip, request }

class _MatchCardContent extends StatelessWidget {
  final MatchItem match;

  const _MatchCardContent({required this.match});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final skills = match.neededSkills.take(3).toList();

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
            color: context.ds.surfaceAlt,
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
        if (skills.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Skills needed',
            style: textTheme.labelMedium?.copyWith(
              color: context.ds.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final skill in skills)
                DsChip(label: skill, variant: DsChipVariant.muted),
            ],
          ),
        ],
        if (match.isFallback) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Skill-based match',
            style: textTheme.labelSmall?.copyWith(color: context.ds.textMuted),
          ),
        ],
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
          isRequest ? 'SAVE' : 'SKIP',
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
