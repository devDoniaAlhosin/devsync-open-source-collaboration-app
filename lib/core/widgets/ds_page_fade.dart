import 'package:flutter/material.dart';

import '../theme/app_animations.dart';

/// Page-level fade + slight rise on first enable.
///
/// Use around screen bodies. Prefer [DsItemEnter] / [DsStagger] for list items.
/// Does **not** re-run when a tab pane becomes tickable again (avoids stacking
/// with [DsTabSwitcher] crossfades).
class DsPageFade extends StatefulWidget {
  const DsPageFade({
    super.key,
    required this.child,
    this.duration = AppAnimations.page,
    this.slide = AppAnimations.itemEnterSlide,
  });

  final Widget child;
  final Duration duration;
  final double slide;

  @override
  State<DsPageFade> createState() => _DsPageFadeState();
}

class _DsPageFadeState extends State<DsPageFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _played = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
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
    _syncWithTickerMode();
  }

  void _syncWithTickerMode() {
    if (_played) return;

    if (WidgetsBinding.instance.disableAnimations ||
        MediaQuery.disableAnimationsOf(context)) {
      _played = true;
      _controller.value = 1;
      return;
    }

    if (!TickerMode.of(context)) return;

    _played = true;
    _controller.forward(from: 0);
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
