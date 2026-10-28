import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ds_icon.dart';

/// Prototype `#intro` hero: rotating dashed rings + floating Build/Match chips.
class IntroOrbitVisual extends StatefulWidget {
  const IntroOrbitVisual({super.key});

  @override
  State<IntroOrbitVisual> createState() => _IntroOrbitVisualState();
}

class _IntroOrbitVisualState extends State<IntroOrbitVisual>
    with TickerProviderStateMixin {
  late final AnimationController _orbit;
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbit.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final reduce = MediaQuery.disableAnimationsOf(context);

    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Soft radial glow
          Container(
            width: 220,
            height: 180,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  AppColors.teal.withValues(alpha: 0.16),
                  AppColors.teal.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                stops: const [0, 0.45, 1],
              ),
            ),
          ),
          // Outer / inner dashed rings
          AnimatedBuilder(
            animation: _orbit,
            builder: (context, _) {
              final t = reduce ? 0.0 : _orbit.value * 2 * math.pi;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: t,
                    child: CustomPaint(
                      size: const Size(148, 148),
                      painter: _DashedRingPainter(
                        color: AppColors.teal.withValues(alpha: 0.32),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -t,
                    child: CustomPaint(
                      size: const Size(112, 112),
                      painter: _DashedRingPainter(
                        color: AppColors.teal.withValues(alpha: 0.28),
                        dash: 5,
                        gap: 4,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Center brand mark
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) {
              final y = reduce ? 0.0 : (_float.value - 0.5) * 8;
              final scale = reduce ? 1.0 : 1 + (_float.value - 0.5) * 0.04;
              return Transform.translate(
                offset: Offset(0, y),
                child: Transform.scale(scale: scale, child: child),
              );
            },
            child: Image.asset(
              AppAssets.iconMint,
              width: 96,
              height: 88,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              color: AppColors.teal,
              colorBlendMode: BlendMode.srcIn,
              semanticLabel: 'DevSync',
            ),
          ),
          // Floating chips
          Positioned(
            left: 4,
            bottom: 22,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, child) {
                final y = reduce ? 0.0 : (_float.value - 0.5) * 10;
                return Transform.translate(
                  offset: Offset(0, y),
                  child: Transform.rotate(angle: -0.08, child: child),
                );
              },
              child: _FloatingChip(
                icon: AppIcons.code,
                label: 'Build',
                border: ds.border,
                surface: ds.surface,
                foreground: ds.accentText,
              ),
            ),
          ),
          Positioned(
            right: 4,
            top: 22,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, child) {
                final y = reduce ? 0.0 : (0.5 - _float.value) * 10;
                return Transform.translate(
                  offset: Offset(0, y),
                  child: Transform.rotate(angle: 0.08, child: child),
                );
              },
              child: _FloatingChip(
                icon: AppIcons.sparkle,
                label: 'Match',
                border: ds.border,
                surface: ds.surface,
                foreground: ds.accentText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingChip extends StatelessWidget {
  const _FloatingChip({
    required this.icon,
    required this.label,
    required this.border,
    required this.surface,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color border;
  final Color surface;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DsIcon(icon, size: 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.ds.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter({required this.color, this.dash = 6, this.gap = 5});

  final Color color;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..strokeCap = StrokeCap.round;

    final radius = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final unit = dash + gap;
    final count = (circumference / unit).floor();

    for (var i = 0; i < count; i++) {
      final start = (i * unit / circumference) * 2 * math.pi;
      final sweep = (dash / circumference) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap;
}

/// Fade + rise entrance used to stagger intro sections.
class IntroEntrance extends StatelessWidget {
  const IntroEntrance({
    super.key,
    required this.animation,
    required this.child,
    this.begin = 0,
    this.end = 1,
  });

  final Animation<double> animation;
  final Widget child;
  final double begin;
  final double end;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: AppAnimations.emphasized),
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
