import 'package:flutter/material.dart';

import '../theme/app_animations.dart';

/// Soft fade + rise for one list/section item.
///
/// Use inside [ListView.builder] so items animate as they are built while
/// scrolling (lazy mount = scroll reveal). Optional [index] adds a short delay
/// for the first screenful.
class DsItemEnter extends StatefulWidget {
  const DsItemEnter({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = AppAnimations.itemEnter,
    this.slide = AppAnimations.itemEnterSlide,
    this.maxDelaySlots = 4,
  });

  final Widget child;

  /// Used to stagger the first visible rows (`index * itemStagger`, capped).
  final int index;
  final Duration duration;
  final double slide;
  final int maxDelaySlots;

  @override
  State<DsItemEnter> createState() => _DsItemEnterState();
}

class _DsItemEnterState extends State<DsItemEnter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.itemEnterCurve,
    );
    _fade = curved;
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slide),
      end: Offset.zero,
    ).animate(curved);
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
    final slots = widget.index.clamp(0, widget.maxDelaySlots);
    final delay = AppAnimations.itemStagger * slots;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(delay, () {
        if (mounted && TickerMode.valuesOf(context).enabled) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
