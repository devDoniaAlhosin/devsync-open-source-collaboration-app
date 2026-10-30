import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_avatar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_merge_mark.dart';

/// Arguments for prototype **15. Connected (celebration)**.
class ConnectedCelebrationArgs {
  const ConnectedCelebrationArgs({
    required this.collaboratorName,
    required this.collaboratorInitials,
    required this.projectName,
    this.myInitials = 'N',
  });

  final String collaboratorName;
  final String collaboratorInitials;
  final String projectName;
  final String myInitials;
}

/// Dark celebration after a collaboration request is accepted.
class ConnectedCelebrationScreen extends StatefulWidget {
  const ConnectedCelebrationScreen({
    super.key,
    required this.args,
  });

  final ConnectedCelebrationArgs args;

  @override
  State<ConnectedCelebrationScreen> createState() =>
      _ConnectedCelebrationScreenState();
}

class _ConnectedCelebrationScreenState extends State<ConnectedCelebrationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _orbit;
  late final AnimationController _copy;
  late final AnimationController _check;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _copy = AnimationController(
      vsync: this,
      duration: AppAnimations.handoff,
    );
    _check = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );

    // Copy rises in after the merge mark has drawn a bit.
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (mounted) _copy.forward();
    });
  }

  @override
  void dispose() {
    _orbit.dispose();
    _copy.dispose();
    _check.dispose();
    super.dispose();
  }

  Animation<double> _slot(double begin, double end) {
    return CurvedAnimation(
      parent: _copy,
      curve: Interval(begin, end, curve: AppAnimations.itemEnterCurve),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstName = widget.args.collaboratorName.split(' ').first;
    final eyebrow = _slot(0.0, 0.45);
    final title = _slot(0.12, 0.55);
    final body = _slot(0.22, 0.65);
    final pair = _slot(0.34, 0.78);
    final cta = _slot(0.48, 1.0);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _orbit,
                      builder: (context, _) {
                        return Transform.rotate(
                          angle: _orbit.value * math.pi * 2,
                          child: CustomPaint(
                            size: const Size(220, 220),
                            painter: _OrbitRingsPainter(progress: _orbit.value),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 10,
                      top: 42,
                      child: _OrbitAvatar(
                        child: DsIcon(
                          AppIcons.profile,
                          size: 16,
                          color: AppColors.darkMuted,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 46,
                      child: _OrbitAvatar(
                        child: Text(
                          widget.args.collaboratorInitials,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    // Animated SVG mark (assets/brand/svg/devsync-icon.svg).
                    DsMergeMark(
                      size: 132,
                      onCompleted: () {
                        if (mounted) _check.forward();
                      },
                    ),
                    Positioned(
                      right: 44,
                      bottom: 44,
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _check,
                          curve: AppAnimations.emphasized,
                        ),
                        child: FadeTransition(
                          opacity: _check,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.teal.withValues(alpha: 0.45),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              AppIcons.success,
                              size: 16,
                              color: AppColors.onTeal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _FadeRise(
                animation: eyebrow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'CONNECTION ESTABLISHED',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FadeRise(
                animation: title,
                child: Text(
                  "You're connected.",
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FadeRise(
                animation: body,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text.rich(
                    TextSpan(
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkMuted,
                        height: 1.55,
                        fontSize: 15,
                      ),
                      children: [
                        TextSpan(text: '$firstName is now collaborating on '),
                        TextSpan(
                          text: '${widget.args.projectName}.',
                          style: const TextStyle(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(
                          text: ' Your next great build starts together.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _FadeRise(
                animation: pair,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 42,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            child: DsAvatar(
                              initials: widget.args.myInitials,
                              size: DsAvatarSize.md,
                            ),
                          ),
                          Positioned(
                            left: 30,
                            child: DsAvatar(
                              initials: widget.args.collaboratorInitials,
                              size: DsAvatarSize.md,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Two minds. One project.',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              _FadeRise(
                animation: cta,
                child: Column(
                  children: [
                    DsButton(
                      label: 'Open task board',
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.tasks,
                          (route) => route.settings.name == AppRoutes.home,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Back to requests',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.darkText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeRise extends StatelessWidget {
  const _FadeRise({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class _OrbitAvatar extends StatelessWidget {
  const _OrbitAvatar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  _OrbitRingsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final r = size.shortestSide * (0.34 + i * 0.12);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = AppColors.teal.withValues(
          alpha: 0.08 + (i == 1 ? 0.06 : 0) + math.sin(progress * math.pi * 2 + i) * 0.02,
        );
      canvas.drawCircle(c, r, paint);

      // Soft dashed arc accent.
      final dash = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = AppColors.teal.withValues(alpha: 0.22);
      final rect = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(
        rect,
        progress * math.pi * 2 + i,
        0.9,
        false,
        dash,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitRingsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
