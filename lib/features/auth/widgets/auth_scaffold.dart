import 'package:flutter/material.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_chip.dart';
import '../../../core/widgets/ds_icon_button.dart';
import '../../../core/widgets/ds_orb.dart';
import '../../../core/widgets/ds_page_header.dart';
import '../../../core/widgets/ds_wordmark.dart';

/// Shared auth page chrome matching prototype topbar-v13:
/// `[back]  ACCOUNT SETUP / title  ……  [theme]`
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    this.title,
    this.eyebrow = 'ACCOUNT SETUP',
    this.showWordmark = false,
    this.showBack = true,
    this.stepLabel,
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

  /// Small caps label above [title] (prototype `.topbar-eyebrow`).
  final String? eyebrow;
  final bool showWordmark;
  final bool showBack;
  final String? stepLabel;
  final VoidCallback? onBack;
  final Widget? bottom;
  final VoidCallback? onThemeToggle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Material(
          color: palette.background,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: palette.border),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (showBack) ...[
                    DsIconButton(
                      icon: AppIcons.back,
                      tooltip: 'Back',
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                    ),
                    // Prototype topbar-v13 gap between lead control and title.
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: title != null
                        ? _AuthTopbarIdentity(
                            eyebrow: eyebrow,
                            title: title!,
                          )
                        : (showWordmark
                            ? const Align(
                                alignment: Alignment.centerLeft,
                                child: DsWordmark(fontSize: 20),
                              )
                            : const SizedBox.shrink()),
                  ),
                  if (stepLabel != null) ...[
                    const SizedBox(width: 8),
                    DsChip(
                      label: stepLabel!,
                      variant: DsChipVariant.outline,
                    ),
                  ],
                  if (onThemeToggle != null) ...[
                    const SizedBox(width: 8),
                    DsIconButton(
                      icon: palette.isDark ? AppIcons.sun : AppIcons.moon,
                      tooltip:
                          palette.isDark ? 'Light theme' : 'Dark theme',
                      onPressed: onThemeToggle,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: padding,
                children: [body],
              ),
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

/// Eyebrow + heading block next to the back control.
class _AuthTopbarIdentity extends StatelessWidget {
  const _AuthTopbarIdentity({
    required this.title,
    this.eyebrow,
  });

  final String title;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = DevSyncPalette.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null && eyebrow!.isNotEmpty)
          Text(
            eyebrow!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: palette.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 9,
              height: 1.3,
              letterSpacing: 1.2,
            ),
          ),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: palette.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            height: 1.25,
            letterSpacing: -0.6,
          ),
        ),
      ],
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
          child: DsPageHeader(
            eyebrow: eyebrow,
            title: title,
            body: body,
          ),
        ),
      ],
    );
  }
}

/// Muted note card used under auth forms.
class AuthNote extends StatelessWidget {
  const AuthNote({
    super.key,
    required this.title,
    required this.message,
  });

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
