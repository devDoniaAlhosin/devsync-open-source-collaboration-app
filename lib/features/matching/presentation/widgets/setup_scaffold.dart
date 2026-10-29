import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/icons/app_icons.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_colors.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_chip.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_icon_button.dart';

class SetupScaffold extends StatelessWidget {
  const SetupScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.body,
    this.stepLabel,
    this.bottom,
    this.onBack,
    this.onThemeToggle,
  });

  final String eyebrow;
  final String title;
  final String? stepLabel;
  final Widget body;
  final Widget? bottom;
  final VoidCallback? onBack;
  final VoidCallback? onThemeToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  DsIconButton(
                    icon: AppIcons.back,
                    tooltip: 'Back',
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: ds.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.6,
                          ),
                        ),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineSmall?.copyWith(
                            color: ds.textPrimary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (stepLabel != null) ...[
                    DsChip(label: stepLabel!, variant: DsChipVariant.outline),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (onThemeToggle != null)
                    DsIconButton(
                      icon: ds.isDark ? AppIcons.sun : AppIcons.moon,
                      tooltip: ds.isDark ? 'Light theme' : 'Dark theme',
                      onPressed: onThemeToggle,
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: ds.border),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                  AppSpacing.screenPadding,
                  AppSpacing.xl,
                ),
                children: [body],
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.sm,
                  AppSpacing.screenPadding,
                  AppSpacing.lg,
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}
