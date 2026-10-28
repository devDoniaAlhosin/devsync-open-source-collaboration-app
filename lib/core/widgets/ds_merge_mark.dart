import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';

/// Animated DevSync merge mark — two branches drawing into one node.
class DsMergeMark extends StatefulWidget {
  const DsMergeMark({
    super.key,
    this.size = 112,
    this.autoPlay = true,
    this.loop = false,
    this.onCompleted,
  });

  final double size;
  final bool autoPlay;
  final bool loop;
  final VoidCallback? onCompleted;

  @override
  State<DsMergeMark> createState() => _DsMergeMarkState();
}

class _DsMergeMarkState extends State<DsMergeMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _draw;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _draw = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.72, curve: AppAnimations.emphasized),
    );
    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1, curve: Curves.easeOut),
    );

    if (widget.autoPlay) {
      _controller.addStatusListener(_onStatus);
      if (widget.loop) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    } else {
      _controller.value = 1;
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glow = 0.18 + _pulse.value * 0.22;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.forest,
            boxShadow: [
              BoxShadow(
                color: AppColors.teal.withValues(alpha: glow),
                blurRadius: 28 + _pulse.value * 18,
                spreadRadius: _pulse.value * 2,
              ),
              BoxShadow(
                color: AppColors.forest.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _MergePainter(progress: _draw.value, pulse: _pulse.value),
          ),
        );
      },
    );
  }
}

class _MergePainter extends CustomPainter {
  _MergePainter({required this.progress, required this.pulse});

  final double progress;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Layout in a 0..1 box inside the circle padding.
    final left = cx - s * 0.28;
    final right = cx + s * 0.28;
    final topY = cy - s * 0.18;
    final midY = cy;
    final botY = cy + s * 0.18;
    final rSmall = s * 0.055;
    final rLarge = s * 0.078;

    final paint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..color = AppColors.teal;

    // Branch paths (cubic curves into the sink).
    final topPath = Path()
      ..moveTo(left, topY)
      ..cubicTo(
        left + s * 0.18,
        topY,
        right - s * 0.16,
        midY - s * 0.02,
        right,
        midY,
      );
    final botPath = Path()
      ..moveTo(left, botY)
      ..cubicTo(
        left + s * 0.18,
        botY,
        right - s * 0.16,
        midY + s * 0.02,
        right,
        midY,
      );

    // Draw curves with reveal.
    final topMetric = topPath.computeMetrics().first;
    final botMetric = botPath.computeMetrics().first;
    final topLen = topMetric.length * progress.clamp(0.0, 1.0);
    final botLen = botMetric.length * progress.clamp(0.0, 1.0);

    if (topLen > 0) {
      canvas.drawPath(topMetric.extractPath(0, topLen), paint);
    }
    if (botLen > 0) {
      canvas.drawPath(botMetric.extractPath(0, botLen), paint);
    }

    // Source nodes appear early.
    final nodeT = ((progress - 0.05) / 0.25).clamp(0.0, 1.0);
    if (nodeT > 0) {
      canvas.drawCircle(Offset(left, topY), rSmall * nodeT, fill);
      canvas.drawCircle(Offset(left, botY), rSmall * nodeT, fill);
    }

    // Sink node grows as branches arrive.
    final sinkT = ((progress - 0.45) / 0.4).clamp(0.0, 1.0);
    if (sinkT > 0) {
      final sinkR = rLarge * (0.55 + 0.45 * sinkT) * (1 + pulse * 0.06);
      canvas.drawCircle(Offset(right, midY), sinkR, fill);

      // Soft inner highlight.
      final hi = Paint()
        ..shader = ui.Gradient.radial(
          Offset(right - sinkR * 0.25, midY - sinkR * 0.25),
          sinkR,
          [Colors.white.withValues(alpha: 0.28 * sinkT), Colors.transparent],
        );
      canvas.drawCircle(Offset(right, midY), sinkR, hi);
    }

    // Subtle orbit ring as merge completes.
    if (pulse > 0) {
      final ring = Paint()
        ..color = AppColors.teal.withValues(alpha: 0.22 * (1 - pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(Offset(cx, cy), s * 0.42 * (0.9 + pulse * 0.15), ring);
    }
  }

  @override
  bool shouldRepaint(covariant _MergePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.pulse != pulse;
}
