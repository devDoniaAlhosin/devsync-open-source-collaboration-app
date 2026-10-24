import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_orb.dart';
import '../../../../core/widgets/ds_page_header.dart';

/// Auth page chrome using the shared [DsAppBar].
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBack = true,
    this.onBack,
    this.bottom,
    this.onThemeToggle,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.screenPadding,
      AppSpacing.sm,
      AppSpacing.screenPadding,
      AppSpacing.xxl,
    ),
  });

  final Widget body;
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? bottom;
  final VoidCallback? onThemeToggle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DsAppBar(
        title: title ?? '',
        showBack: showBack,
        onBack: onBack,
        onThemeToggle: onThemeToggle,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(padding: padding, children: [body]),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  0,
                  AppSpacing.screenPadding,
                  AppSpacing.xxl,
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

/// Orb + page header row used on recovery / verify screens.
class AuthInlineHeading extends StatelessWidget {
  const AuthInlineHeading({
    super.key,
    required this.orbIcon,
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final IconData orbIcon;
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DsOrb(icon: orbIcon, size: 72),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: DsPageHeader(eyebrow: eyebrow, title: title, body: body),
        ),
      ],
    );
  }
}

/// Muted note card used under auth forms.
class AuthNote extends StatelessWidget {
  const AuthNote({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = DevSyncPalette.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: palette.border),
      ),
      child: RichText(
        text: TextSpan(
          style: textTheme.bodySmall?.copyWith(color: palette.textMuted),
          children: [
            TextSpan(
              text: '$title ',
              style: textTheme.bodySmall?.copyWith(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: message),
          ],
        ),
      ),
    );
  }
}
