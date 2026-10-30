import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_page_fade.dart';
import '../../../../core/widgets/ds_staggered_entrance.dart';

/// Arguments for prototype **12. Notification permission**.
class NotificationPermissionArgs {
  const NotificationPermissionArgs({
    required this.maintainerName,
    required this.projectName,
  });

  final String maintainerName;
  final String projectName;
}

/// Soft-ask before the OS prompt — Allow / Not now both open Requests.
class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({
    super.key,
    required this.args,
  });

  final NotificationPermissionArgs args;

  static const int requestsTabIndex = 3;

  void _goToRequests(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
      arguments: requestsTabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final name = args.maintainerName;
    final project = args.projectName;

    return Scaffold(
      backgroundColor: ds.background,
      body: SafeArea(
        child: DsPageFade(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xxxl,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PushDropIn(
                      child: _PushPreview(
                        title: '$name accepted your request',
                        subtitle: '$project · now',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    DsStagger(
                      mainAxisSize: MainAxisSize.min,
                      spacing: AppSpacing.md,
                      children: [
                        Text(
                          "Don't miss $name's reply",
                          textAlign: TextAlign.center,
                          style: textTheme.displaySmall?.copyWith(
                            color: ds.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'We only alert you about requests, replies and '
                          'project updates. No marketing.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: ds.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(flex: 3),
                DsStagger(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.md,
                  children: [
                    DsButton(
                      label: 'Allow notifications',
                      onPressed: () => _goToRequests(context),
                    ),
                    DsButton(
                      label: 'Not now',
                      variant: DsButtonVariant.secondary,
                      onPressed: () => _goToRequests(context),
                    ),
                    Text(
                      'Your request is saved either way.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Prototype `.push` drop: fade + fall from −40px after a short delay.
class _PushDropIn extends StatefulWidget {
  const _PushDropIn({required this.child});

  final Widget child;

  static const _delay = Duration(milliseconds: 300);
  static const _duration = Duration(milliseconds: 800);
  static const _fromY = -40.0;

  @override
  State<_PushDropIn> createState() => _PushDropInState();
}

class _PushDropInState extends State<_PushDropIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _PushDropIn._duration,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.emphasized,
    );
    _fade = curved;
    _slide = Tween<Offset>(
      begin: const Offset(0, _PushDropIn._fromY),
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
    Future<void>.delayed(_PushDropIn._delay, () {
      if (mounted && TickerMode.valuesOf(context).enabled) {
        _controller.forward();
      }
    });
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
      child: AnimatedBuilder(
        animation: _slide,
        builder: (context, child) {
          return Transform.translate(
            offset: _slide.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _PushPreview extends StatelessWidget {
  const _PushPreview({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: ds.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: ds.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.forest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusIcon),
            ),
            child: const Center(
              child: DsIcon(
                AppIcons.github,
                size: 22,
                color: AppColors.darkText,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: ds.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: ds.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
