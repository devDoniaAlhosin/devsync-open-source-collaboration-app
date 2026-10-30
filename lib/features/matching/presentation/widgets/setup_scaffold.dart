import 'package:flutter/material.dart';
import 'package:devsync_open_source_collaboration_app/core/theme/app_spacing.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_app_bar.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_chip.dart';

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
    return Scaffold(
      appBar: DsAppBar(
        title: title,
        eyebrow: eyebrow,
        showBack: true,
        onBack: onBack ?? () => Navigator.of(context).maybePop(),
        onThemeToggle: onThemeToggle,
        actions: [
          if (stepLabel != null)
            DsChip(label: stepLabel!, variant: DsChipVariant.outline),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
    );
  }
}
