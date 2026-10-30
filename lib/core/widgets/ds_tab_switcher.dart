import 'package:flutter/material.dart';

import '../theme/app_animations.dart';

/// Keep-alive tab body host: mounts a pane on first visit and crossfades
/// between panes. Inactive panes stay onstage until their fade-out finishes,
/// then are [Offstage]'d to avoid work while hidden.
class DsTabSwitcher extends StatefulWidget {
  const DsTabSwitcher({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppAnimations.tabCrossfade,
    this.curve = AppAnimations.tabCrossfadeCurve,
  });

  final int index;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  @override
  State<DsTabSwitcher> createState() => _DsTabSwitcherState();
}

class _DsTabSwitcherState extends State<DsTabSwitcher> {
  late final Set<int> _activated;

  @override
  void initState() {
    super.initState();
    _activated = {widget.index.clamp(0, widget.children.length - 1)};
  }

  @override
  void didUpdateWidget(covariant DsTabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.index.clamp(0, widget.children.length - 1);
    if (!_activated.contains(next)) {
      setState(() => _activated.add(next));
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.children.isNotEmpty, 'DsTabSwitcher requires at least one child');
    assert(
      widget.index >= 0 && widget.index < widget.children.length,
      'DsTabSwitcher index ${widget.index} is out of range for '
      '${widget.children.length} children',
    );

    final index = widget.index;
    final motion = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : widget.duration;

    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (_activated.contains(i))
            _TabPane(
              selected: i == index,
              duration: motion,
              curve: widget.curve,
              child: widget.children[i],
            ),
      ],
    );
  }
}

class _TabPane extends StatefulWidget {
  const _TabPane({
    required this.selected,
    required this.duration,
    required this.curve,
    required this.child,
  });

  final bool selected;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  State<_TabPane> createState() => _TabPaneState();
}

class _TabPaneState extends State<_TabPane>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late bool _onstage;

  @override
  void initState() {
    super.initState();
    _onstage = widget.selected;
    _fade = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.selected ? 1 : 0,
    )..addStatusListener(_onFadeStatus);
  }

  void _onFadeStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && !widget.selected && _onstage) {
      setState(() => _onstage = false);
    }
  }

  @override
  void didUpdateWidget(covariant _TabPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _fade.duration = widget.duration;
    }
    if (widget.selected && !oldWidget.selected) {
      final wasOff = !_onstage;
      if (wasOff) {
        setState(() => _onstage = true);
      }
      if (widget.duration == Duration.zero) {
        _fade.value = 1;
      } else if (wasOff || _fade.value == 0) {
        _fade.forward(from: 0);
      } else {
        // Mid reverse — ease back in from the current opacity.
        _fade.forward();
      }
    } else if (!widget.selected && oldWidget.selected) {
      if (widget.duration == Duration.zero) {
        _fade.value = 0;
        if (_onstage) setState(() => _onstage = false);
      } else {
        _fade.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fade
      ..removeStatusListener(_onFadeStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.selected;
    return Offstage(
      offstage: !_onstage,
      child: TickerMode(
        // Keep tickers alive while fading out so the reverse runs.
        enabled: _onstage,
        child: IgnorePointer(
          ignoring: !active,
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _fade, curve: widget.curve),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
