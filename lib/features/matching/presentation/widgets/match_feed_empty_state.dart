import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_brand_icon.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_github_icon.dart';

class MatchFeedEmptyState extends StatelessWidget {
  final VoidCallback onAddSkills;

  final VoidCallback onConnectGitHub;
  final VoidCallback? onRefresh;
  final bool hasSkills;
  final bool hasReviewedAll;
  const MatchFeedEmptyState({
    super.key,
    required this.onAddSkills,
    required this.onConnectGitHub,
    this.onRefresh,
    this.hasSkills = false,
    this.hasReviewedAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 128,
                        height: 128,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: context.ds.surface,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const DsBrandIcon(size: 64),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      hasReviewedAll
                          ? 'You have reviewed every match'
                          : 'No matches yet',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: context.ds.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      hasReviewedAll
                          ? 'Your saved projects are in Liked matches. Refresh to check for new recommendations.'
                          : hasSkills
                          ? 'No eligible projects were returned. Try again later or update your matching preferences.'
                          : 'Add your skills to your saved profile to find relevant projects.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.ds.textMuted,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (onRefresh != null) ...[
                      DsButton(label: 'Refresh matches', onPressed: onRefresh),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    DsButton(label: 'Add skills', onPressed: onAddSkills),
                    const SizedBox(height: AppSpacing.md),
                    DsButton(
                      label: 'GitHub profile',
                      leading: DsGithubIcon(
                        size: 18,
                        color: context.ds.textPrimary,
                      ),
                      variant: DsButtonVariant.quiet,
                      onPressed: onConnectGitHub,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
