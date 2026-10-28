import 'package:material_ui/material_ui.dart';

import '../../../core/icons/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/ds_chip.dart';
import '../../../core/widgets/ds_icon_button.dart';
import '../../../core/widgets/ds_orb.dart';
import '../../../core/widgets/ds_page_header.dart';
import '../../../core/widgets/ds_wordmark.dart';

/// Shared auth page chrome: back, title/wordmark, optional chip / theme action.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.body,
    this.title,
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
  final bool showWordmark;
  final bool showBack;
  final String? stepLabel;
  final VoidCallback? onBack;
  final Widget? bottom;
  final VoidCallback? onThemeToggle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: DsIconButton(
                  icon: AppIcons.back,
                  tooltip: 'Back',
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              )
            : null,
        title: title != null
            ? Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: context.ds.textPrimary),
              )
            : (showWordmark ? const DsWordmark(fontSize: 20) : null),
        actions: [
          if (stepLabel != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Center(
                child: DsChip(
                  label: stepLabel!,
                  variant: DsChipVariant.outline,
                ),
              ),
            ),
          if (onThemeToggle != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: DsIconButton(
                icon: context.ds.isDark ? AppIcons.sun : AppIcons.moon,
                tooltip: context.ds.isDark ? 'Light theme' : 'Dark theme',
                onPressed: onThemeToggle,
              ),
            ),
        ],
      ),
      body: SafeArea(
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
