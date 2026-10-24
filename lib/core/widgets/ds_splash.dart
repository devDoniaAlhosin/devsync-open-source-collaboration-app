import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_animations.dart';
import '../theme/app_colors.dart';
import 'ds_merge_mark.dart';
import 'ds_wordmark.dart';

/// Launch splash: merge mark draws, then hands off into the first page.
class DsSplash extends StatefulWidget {
  const DsSplash({
    super.key,
    this.message,
    this.showWordmark = true,
    this.onReveal,
    this.onFinished,
    this.holdAfterMerge = const Duration(milliseconds: 420),
  });

  final String? message;
  final bool showWordmark;

  /// App content can mount underneath before this layer fades.
  final VoidCallback? onReveal;
  final VoidCallback? onFinished;

  /// Extra beat after the merge finishes before the handoff.
  final Duration holdAfterMerge;

  @override
  State<DsSplash> createState() => _DsSplashState();
}

class _DsSplashState extends State<DsSplash> with TickerProviderStateMixin {
  late final AnimationController _ambient;
  late final AnimationController _copy;
  late final AnimationController _handoff;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.forest,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _copy = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _handoff = AnimationController(
      vsync: this,
      duration: AppAnimations.handoff,
    );

    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (mounted) _copy.forward();
    });
  }

  @override
  void dispose() {
    _ambient.dispose();
    _copy.dispose();
    _handoff.dispose();
    super.dispose();
  }

  Future<void> _onMergeConnected() async {
    if (_finished || !mounted) return;
    await Future<void>.delayed(widget.holdAfterMerge);
    if (!mounted || _finished) return;
    _finished = true;
    widget.onReveal?.call();
    await _handoff.forward();
    if (!mounted) return;
    widget.onFinished?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final veil = CurvedAnimation(
      parent: _handoff,
      curve: const Interval(0, 0.75, curve: AppAnimations.emphasized),
    );
    final markFade = CurvedAnimation(
      parent: _handoff,
      curve: const Interval(0.45, 1, curve: AppAnimations.emphasized),
    );
    final markScale = Tween<double>(begin: 1, end: 0.84).animate(
      CurvedAnimation(parent: _handoff, curve: AppAnimations.emphasized),
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.forest,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: Tween<double>(begin: 1, end: 0).animate(veil),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.launchGradient,
                ),
                child: AnimatedBuilder(
                  animation: _ambient,
                  builder: (context, _) => CustomPaint(
                    painter: _SplashAmbientPainter(t: _ambient.value),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0).animate(markFade),
                    child: ScaleTransition(
                      scale: markScale,
                      child: DsMergeMark(
                        size: 148,
                        onCompleted: _onMergeConnected,
                      ),
                    ),
                  ),
                  if (widget.showWordmark) ...[
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: Tween<double>(begin: 1, end: 0).animate(veil),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _copy,
                          curve: const Interval(
                            0.15,
                            0.75,
                            curve: AppAnimations.emphasized,
                          ),
                        ),
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.18),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _copy,
                              curve: const Interval(
                                0.15,
                                0.85,
                                curve: AppAnimations.emphasized,
                              ),
                            ),
                          ),
                          child: const DsWordmark(
                            fontSize: 38,
                            devColor: AppColors.mint,
                            syncColor: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0).animate(veil),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _copy,
                        curve: const Interval(
                          0.4,
                          1,
                          curve: AppAnimations.emphasized,
                        ),
                      ),
                      child: Text(
                        widget.message ?? 'Connecting your workspace…',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.mint.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashAmbientPainter extends CustomPainter {
  _SplashAmbientPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.42;

    final bloom = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.teal.withValues(alpha: 0.22),
          AppColors.teal.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 180));
    canvas.drawCircle(Offset(cx, cy), 180, bloom);

    final orbs = <(Offset, double, double)>[
      (Offset(size.width * 0.18, size.height * 0.22), 46, 0.10),
      (Offset(size.width * 0.82, size.height * 0.28), 58, 0.08),
      (Offset(size.width * 0.22, size.height * 0.72), 70, 0.07),
      (Offset(size.width * 0.78, size.height * 0.68), 52, 0.09),
    ];

    for (var i = 0; i < orbs.length; i++) {
      final (base, r, a) = orbs[i];
      final phase = t * math.pi * 2 + i * 1.1;
      final pos = base.translate(
        math.sin(phase) * 14,
        math.cos(phase * 0.85) * 10,
      );
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.teal.withValues(alpha: a),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: pos, radius: r));
      canvas.drawCircle(pos, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashAmbientPainter oldDelegate) =>
      oldDelegate.t != t;
}
