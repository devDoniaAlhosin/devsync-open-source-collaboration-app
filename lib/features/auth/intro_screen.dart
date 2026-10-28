import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_feature_tile.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_logo.dart';
import '../../core/widgets/ds_wordmark.dart';
import 'widgets/auth_social_buttons.dart';
import 'widgets/intro_orbit_visual.dart';

/// Launch experience (prototype `#intro` / “0. DevSync launch experience”).
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _goWelcome() => Navigator.of(context).pushNamed(AppRoutes.welcome);

  void _goLogin() => Navigator.of(context).pushNamed(AppRoutes.login);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            AppSpacing.xxxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntroEntrance(
                animation: _enter,
                begin: 0,
                end: 0.35,
                child: Row(
                  children: [
                    const DsLogo(variant: DsLogoVariant.icon, height: 26),
                    const SizedBox(width: 8),
                    const DsWordmark(fontSize: 22),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ds.border),
                      ),
                      child: Text(
                        'FOR OPEN-SOURCE BUILDERS',
                        style: textTheme.labelSmall?.copyWith(
                          color: ds.textMuted,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              IntroEntrance(
                animation: _enter,
                begin: 0.08,
                end: 0.5,
                child: const IntroOrbitVisual(),
              ),
              const SizedBox(height: AppSpacing.lg),
              IntroEntrance(
                animation: _enter,
                begin: 0.18,
                end: 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR NEXT GREAT COLLABORATION STARTS HERE',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text.rich(
                      TextSpan(
                        style: textTheme.displayMedium?.copyWith(
                          fontSize: 33,
                          height: 1.12,
                          letterSpacing: -1.6,
                          color: ds.textPrimary,
                        ),
                        children: const [
                          TextSpan(text: 'Find your people.\n'),
                          TextSpan(
                            text: 'Build something real.',
                            style: TextStyle(color: AppColors.teal),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    Text(
                      'Discover projects matched to your skills, meet contributors, and turn ideas into shipped work.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: ds.textMuted,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              IntroEntrance(
                animation: _enter,
                begin: 0.32,
                end: 0.72,
                child: _ProofCard(onTap: _goWelcome),
              ),
              const SizedBox(height: 11),
              IntroEntrance(
                animation: _enter,
                begin: 0.42,
                end: 0.82,
                child: Row(
                  children: [
                    Expanded(
                      child: DsFeatureTile(
                        icon: AppIcons.projects,
                        title: 'Discover',
                        subtitle: 'Find your next project',
                        onTap: _goWelcome,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: DsFeatureTile(
                        icon: AppIcons.success,
                        title: 'Collaborate',
                        subtitle: 'Plan, build, ship',
                        onTap: _goWelcome,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              IntroEntrance(
                animation: _enter,
                begin: 0.55,
                end: 1,
                child: Column(
                  children: [
                    DsButton(
                      label: 'Get started',
                      icon: AppIcons.forward,
                      onPressed: _goWelcome,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: textTheme.bodySmall?.copyWith(
                              color: ds.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          AuthTextLink(label: 'Sign in →', onPressed: _goLogin),
                        ],
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

class _ProofCard extends StatefulWidget {
  const _ProofCard({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_ProofCard> createState() => _ProofCardState();
}

class _ProofCardState extends State<_ProofCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return AnimatedScale(
      scale: _pressed ? AppAnimations.pressScale : 1,
      duration: AppAnimations.fast,
      curve: AppAnimations.emphasized,
      child: Material(
        color: ds.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ds.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ds.surfaceAlt,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: DsIcon(
                    AppIcons.sparkle,
                    size: 18,
                    color: ds.accentText,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smarter discovery, less searching',
                        style: textTheme.titleSmall?.copyWith(
                          color: ds.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'AI-powered fit scores with reasons you can trust',
                        style: textTheme.bodySmall?.copyWith(
                          color: ds.textMuted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                DsIcon(AppIcons.forward, size: 16, color: ds.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
