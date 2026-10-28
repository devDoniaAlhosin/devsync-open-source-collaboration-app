import 'package:flutter/material.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import 'ds_merge_mark.dart';
import 'ds_wordmark.dart';

/// App open splash: mint→teal gradient + animated merge mark.
class DsSplash extends StatefulWidget {
  const DsSplash({
    super.key,
    this.message,
    this.showWordmark = true,
    this.onFinished,
    this.minDuration = const Duration(milliseconds: 1700),
  });

  final String? message;
  final bool showWordmark;
  final VoidCallback? onFinished;
  final Duration minDuration;

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F5F2),
      Color(0xFFD3E9E4),
      Color(0xFFB8DFD6),
      Color(0xFF9FD4C8),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  @override
  State<DsSplash> createState() => _DsSplashState();
}

class _DsSplashState extends State<DsSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  bool _mergeDone = false;
  bool _timerDone = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
      value: 1,
    );
    Future<void>.delayed(widget.minDuration, () {
      _timerDone = true;
      _tryFinish();
    });
  }

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  void _onMergeDone() {
    _mergeDone = true;
    _tryFinish();
  }

  Future<void> _tryFinish() async {
    if (_finished || !mounted) return;
    if (!_mergeDone || !_timerDone) return;
    _finished = true;
    await _fade.reverse();
    if (!mounted) return;
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: DsSplash.gradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DsMergeMark(size: 120, onCompleted: _onMergeDone),
                if (widget.showWordmark) ...[
                  const SizedBox(height: 28),
                  const DsWordmark(fontSize: 34),
                ],
                if (widget.message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    widget.message!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
