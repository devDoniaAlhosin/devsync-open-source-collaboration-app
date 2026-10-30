import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import 'ds_item_enter.dart';

/// Fade + slight rise for a single staggered item.
///
/// Pass an [animation] driven by a parent controller (often from [DsStagger]).
class DsStaggeredEntrance extends StatelessWidget {
  const DsStaggeredEntrance({
    super.key,
    required this.animation,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.slide = 0.06,
  });

  final Animation<double> animation;
  final Widget child;
  final double begin;
  final double end;

  /// Fractional Y offset at the start of the rise (prototype uses ~0.06–0.08).
  final double slide;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: AppAnimations.itemEnterCurve),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, slide),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Owns one [AnimationController] and staggers [children] by index.
///
/// Starts only when [TickerMode] is enabled (so Offstage tab panes still fade).
/// Caps the active stagger window at [maxStaggered] items.
///
/// For long scrollable lists prefer [ListView.builder] + [DsItemEnter].
class DsStagger extends StatefulWidget {
  const DsStagger({
    super.key,
    required this.children,
    this.duration = AppAnimations.rise,
    this.stagger = AppAnimations.itemStagger,
    this.maxStaggered = 8,
    this.slide = AppAnimations.itemEnterSlide,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.spacing = 0,
  });

  final List<Widget> children;
  final Duration duration;
  final Duration stagger;
  final int maxStaggered;
  final double slide;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  @override
  State<DsStagger> createState() => _DsStaggerState();
}

class _DsStaggerState extends State<DsStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryStart();
  }

  void _tryStart() {
    if (_started) return;
    if (WidgetsBinding.instance.disableAnimations ||
        MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _controller.value = 1;
      return;
    }
    if (!TickerMode.valuesOf(context).enabled) return;
    _started = true;
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (double, double) _intervalFor(int index, int count) {
    if (count <= 1) return (0, 1);
    final staggeredCount = count.clamp(1, widget.maxStaggered);
    final stepMs = widget.stagger.inMilliseconds.toDouble();
    final totalMs = widget.duration.inMilliseconds.toDouble();
    final window = (stepMs * (staggeredCount - 1) / totalMs).clamp(0.0, 0.7);
    final slot = index.clamp(0, staggeredCount - 1);
    final begin = staggeredCount == 1
        ? 0.0
        : (slot / (staggeredCount - 1)) * window;
    final end = (begin + (1 - window)).clamp(0.05, 1.0);
    return (begin, end);
  }

  @override
  Widget build(BuildContext context) {
    final kids = widget.children;
    if (kids.isEmpty) return const SizedBox.shrink();

    // Short lists: coordinated stagger. Long lists: per-item enter so
    // off-screen rows still fade when a parent rebuilds them.
    if (kids.length > widget.maxStaggered) {
      return Column(
        mainAxisSize: widget.mainAxisSize,
        crossAxisAlignment: widget.crossAxisAlignment,
        children: [
          for (var i = 0; i < kids.length; i++) ...[
            if (i > 0 && widget.spacing > 0) SizedBox(height: widget.spacing),
            DsItemEnter(
              index: i,
              slide: widget.slide,
              child: kids[i],
            ),
          ],
        ],
      );
    }

    return Column(
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        for (var i = 0; i < kids.length; i++) ...[
          if (i > 0 && widget.spacing > 0) SizedBox(height: widget.spacing),
          Builder(
            builder: (context) {
              final (begin, end) = _intervalFor(i, kids.length);
              return DsStaggeredEntrance(
                animation: _controller,
                begin: begin,
                end: end,
                slide: widget.slide,
                child: kids[i],
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Interval helpers when a screen owns its own [AnimationController].
abstract final class DsStaggerTiming {
  /// Returns `(begin, end)` for [index] among [count] items.
  static (double, double) interval(
    int index,
    int count, {
    Duration duration = AppAnimations.rise,
    Duration stagger = AppAnimations.itemStagger,
    int maxStaggered = 8,
  }) {
    if (count <= 1) return (0, 1);
    final staggeredCount = count.clamp(1, maxStaggered);
    final stepMs = stagger.inMilliseconds.toDouble();
    final totalMs = duration.inMilliseconds.toDouble();
    final window = (stepMs * (staggeredCount - 1) / totalMs).clamp(0.0, 0.7);
    final slot = index.clamp(0, staggeredCount - 1);
    final begin = staggeredCount == 1
        ? 0.0
        : (slot / (staggeredCount - 1)) * window;
    final end = (begin + (1 - window)).clamp(0.05, 1.0);
    return (begin, end);
  }
}
