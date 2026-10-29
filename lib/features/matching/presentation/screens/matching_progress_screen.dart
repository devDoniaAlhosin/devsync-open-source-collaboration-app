import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../widgets/matching_progress_content.dart';

export '../widgets/matching_progress_content.dart' show MatchingProgressPhase;

/// Displays progress reported by the matching operation; it owns no requests.
class MatchingProgressScreen extends StatelessWidget {
  final MatchingProgressPhase phase;

  final int? repositoryCount;
  final int? languageCount;
  final int? projectCount;
  final VoidCallback? onBack;
  const MatchingProgressScreen({
    super.key,
    this.phase = MatchingProgressPhase.readActivity,
    this.repositoryCount,
    this.languageCount,
    this.projectCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ds.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      SizedBox.square(
                        dimension: AppSpacing.minTouchTarget,
                        child: DsIconButton(
                          icon: AppIcons.back,
                          tooltip: 'Back',
                          onPressed:
                              onBack ?? () => Navigator.of(context).maybePop(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WORKSPACE',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: context.ds.textMuted,
                                    fontSize: 10,
                                    letterSpacing: 1.4,
                                  ),
                            ),
                            Text(
                              'Finding matches',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: context.ds.border),
                Expanded(
                  child: MatchingProgressContent(
                    phase: phase,
                    repositoryCount: repositoryCount,
                    languageCount: languageCount,
                    projectCount: projectCount,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
