import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';

/// Animated DevSync merge mark — matches [assets/brand/svg/devsync-icon.svg].
///
/// Two source nodes draw curves into one sink node, then pulse.
class DsMergeMark extends StatefulWidget {
  const DsMergeMark({
    super.key,
    this.size = 112,
    this.autoPlay = true,
    this.loop = false,
    this.onCompleted,
    this.interactive = false,
  });

  final double size;
  final bool autoPlay;
  final bool loop;
  final VoidCallback? onCompleted;

  /// Tap restarts a soft pulse when the draw animation has finished.
  final bool interactive;

  @override
  State<DsMergeMark> createState() => _DsMergeMarkState();
}

class _DsMergeMarkState extends State<DsMergeMark>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _idle;
  late final Animation<double> _draw;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _draw = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.7, curve: AppAnimations.emphasized),
    );
    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.52, 1, curve: Curves.easeOut),
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
      _idle.repeat(reverse: true);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onCompleted?.call();
      if (mounted && !widget.loop) {
        _idle.repeat(reverse: true);
      }
    }
  }

  void _onTap() {
    if (!widget.interactive) return;
    if (_controller.isAnimating) {
      _controller.fling(velocity: 1.8);
      return;
    }
    _idle.stop();
    _controller
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.interactive ? _onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _idle]),
        builder: (context, _) {
          final idle = _idle.isAnimating ? _idle.value : 0.0;
          final glow = 0.2 + _pulse.value * 0.28 + idle * 0.08;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.forest,
                  AppColors.forest.withValues(alpha: 0.92),
                  const Color(0xFF0A1F1D),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: glow),
                  blurRadius: 32 + _pulse.value * 22 + idle * 10,
                  spreadRadius: _pulse.value * 3,
                ),
                BoxShadow(
                  color: AppColors.forest.withValues(alpha: 0.28),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: CustomPaint(
              painter: _MergePainter(
                progress: _draw.value,
                pulse: _pulse.value,
                idle: idle,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MergePainter extends CustomPainter {
  _MergePainter({
    required this.progress,
    required this.pulse,
    required this.idle,
  });

  final double progress;
  final double pulse;
  final double idle;

  @override
  void paint(Canvas canvas, Size size) {
    // SVG viewBox "20 30 168 140" → normalized inside the circle.
    final s = size.shortestSide;
    final pad = s * 0.14;
    final vbW = 168.0;
    final vbH = 140.0;
    final scale = (s - pad * 2) / math.max(vbW, vbH);
    final ox = (size.width - vbW * scale) / 2;
    final oy = (size.height - vbH * scale) / 2 - s * 0.02;

    Offset pt(double x, double y) =>
        Offset(ox + (x - 20) * scale, oy + (y - 30) * scale);

    final leftTop = pt(48, 58);
    final leftBot = pt(48, 142);
    final sink = pt(154, 100);
    final rSmall = 16 * scale;
    final rLarge = 22 * scale * (1 + pulse * 0.05 + idle * 0.03);
    final strokeW = 11 * scale;

    final paint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..color = AppColors.teal;

    // Paths from SVG:
    // M64 58 C110 58 100 100 132 100
    // M64 142 C110 142 100 100 132 100
    final topPath = Path()
      ..moveTo(pt(64, 58).dx, pt(64, 58).dy)
      ..cubicTo(
        pt(110, 58).dx,
        pt(110, 58).dy,
        pt(100, 100).dx,
        pt(100, 100).dy,
        pt(132, 100).dx,
        pt(132, 100).dy,
      );
    final botPath = Path()
      ..moveTo(pt(64, 142).dx, pt(64, 142).dy)
      ..cubicTo(
        pt(110, 142).dx,
        pt(110, 142).dy,
        pt(100, 100).dx,
        pt(100, 100).dy,
        pt(132, 100).dx,
        pt(132, 100).dy,
      );

    final topMetric = topPath.computeMetrics().first;
    final botMetric = botPath.computeMetrics().first;
    final t = progress.clamp(0.0, 1.0);

    if (t > 0) {
      canvas.drawPath(topMetric.extractPath(0, topMetric.length * t), paint);
      canvas.drawPath(botMetric.extractPath(0, botMetric.length * t), paint);
    }

    // Energy dots traveling along each branch.
    if (t > 0.08 && t < 0.98) {
      final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      final glowPaint = Paint()
        ..color = AppColors.teal.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      for (final metric in [topMetric, botMetric]) {
        final pos = metric.getTangentForOffset(metric.length * t)?.position;
        if (pos == null) continue;
        canvas.drawCircle(pos, strokeW * 0.55, glowPaint);
        canvas.drawCircle(pos, strokeW * 0.28, dotPaint);
      }
    }

    // Source nodes appear early.
    final nodeT = ((progress - 0.02) / 0.22).clamp(0.0, 1.0);
    if (nodeT > 0) {
      canvas.drawCircle(leftTop, rSmall * nodeT, fill);
      canvas.drawCircle(leftBot, rSmall * nodeT, fill);
    }

    // Sink node grows as branches arrive.
    final sinkT = ((progress - 0.42) / 0.4).clamp(0.0, 1.0);
    if (sinkT > 0) {
      final sinkR = rLarge * (0.5 + 0.5 * sinkT);
      canvas.drawCircle(sink, sinkR, fill);

      final hi = Paint()
        ..shader = ui.Gradient.radial(
          sink.translate(-sinkR * 0.28, -sinkR * 0.28),
          sinkR,
          [
            Colors.white.withValues(alpha: 0.32 * sinkT),
            Colors.transparent,
          ],
        );
      canvas.drawCircle(sink, sinkR, hi);
    }

    // Soft completion rings.
    if (pulse > 0) {
      final ring = Paint()
        ..color = AppColors.teal.withValues(alpha: 0.28 * (1 - pulse * 0.55))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      final cx = size.width / 2;
      final cy = size.height / 2;
      canvas.drawCircle(
        Offset(cx, cy),
        s * 0.44 * (0.88 + pulse * 0.18),
        ring,
      );
      canvas.drawCircle(
        Offset(cx, cy),
        s * 0.44 * (0.95 + pulse * 0.28),
        ring..color = AppColors.teal.withValues(alpha: 0.12 * (1 - pulse)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MergePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.pulse != pulse ||
      oldDelegate.idle != idle;
}
