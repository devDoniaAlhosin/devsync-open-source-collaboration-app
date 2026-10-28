import 'package:material_ui/material_ui.dart';

import '../../app/app_routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_animations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_avatar.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_chip.dart';
import '../../core/widgets/ds_logo.dart';
import '../../core/widgets/ds_score_meter.dart';
import '../../core/widgets/ds_wordmark.dart';
import 'widgets/auth_social_buttons.dart';

/// Prototype “1. Welcome (swipe carousel)”.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pageController = PageController();
  int _index = 0;

  static const _slides = [
    _SlideData(
      title: 'Code with the right people.',
      body:
          'Find open-source projects that fit your skills, matched from your real GitHub activity.',
      visual: _SlideVisual.brand,
    ),
    _SlideData(
      title: 'Know exactly why it fits.',
      body:
          'Every match has a score and a one-line reason. Like or skip to teach it what you want.',
      visual: _SlideVisual.match,
    ),
    _SlideData(
      title: 'Ask. Get alerted. Build.',
      body:
          'Send one request, get a push the moment a maintainer replies, then plan tasks together.',
      visual: _SlideVisual.connect,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _slides.length - 1) {
      _pageController.nextPage(
        duration: AppAnimations.page,
        curve: AppAnimations.emphasized,
      );
    } else {
      Navigator.of(context).pushNamed(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.lg,
            AppSpacing.screenPadding,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const DsLogo(variant: DsLogoVariant.icon, height: 26),
                  const SizedBox(width: 8),
                  const DsWordmark(fontSize: 22),
                  const Spacer(),
                  AuthGithubSignInLink(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.login),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  DsChip(
                    label:
                        '${(_index + 1).toString().padLeft(2, '0')} / 0${_slides.length}',
                    variant: DsChipVariant.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Discover · Match · Ship',
                    style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final slide = _slides[i];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _SlideVisualView(type: slide.visual)),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          slide.title,
                          style: textTheme.displayMedium?.copyWith(
                            color: ds.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          slide.body,
                          style: textTheme.bodyLarge?.copyWith(
                            color: ds.textMuted,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final on = i == _index;
                  return AnimatedContainer(
                    duration: AppAnimations.normal,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: on ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: on ? AppColors.teal : ds.border,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xl),
              DsButton(
                label: isLast ? 'Get started' : 'Next',
                icon: AppIcons.forward,
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SlideVisual { brand, match, connect }

class _SlideData {
  const _SlideData({
    required this.title,
    required this.body,
    required this.visual,
  });

  final String title;
  final String body;
  final _SlideVisual visual;
}

class _SlideVisualView extends StatelessWidget {
  const _SlideVisualView({required this.type});

  final _SlideVisual type;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return LayoutBuilder(
      builder: (context, constraints) {
        final child = switch (type) {
          _SlideVisual.brand => const _WelcomeHeroMark(),
          _SlideVisual.match => Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: ds.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(color: ds.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const DsProjectAvatar(label: 'FC'),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'flutter-oss/charts',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: ds.textPrimary,
                                ),
                          ),
                          Text(
                            'Needs a Dart contributor',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: ds.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const DsScoreRing(score: 92, size: 54),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.forest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'You shipped 14 Dart repos and Firebase auth twice.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _SlideVisual.connect => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const DsAvatar(initials: 'N', size: DsAvatarSize.lg),
              Container(
                width: 48,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const DsAvatar(initials: 'K', size: DsAvatarSize.lg),
            ],
          ),
        };

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Dark hero panel from prototype `.hero` (slide 1).
class _WelcomeHeroMark extends StatelessWidget {
  const _WelcomeHeroMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10252B), Color(0xFF0B161C)],
        ),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.darkBorder.withValues(alpha: 0.7),
                width: 1.5,
              ),
            ),
          ),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.darkBorder.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
          ),
          Image.asset(
            AppAssets.iconMint,
            width: 140,
            height: 118,
            fit: BoxFit.contain,
            color: AppColors.teal,
            colorBlendMode: BlendMode.srcIn,
            filterQuality: FilterQuality.high,
            semanticLabel: 'DevSync',
          ),
        ],
      ),
    );
  }
}
