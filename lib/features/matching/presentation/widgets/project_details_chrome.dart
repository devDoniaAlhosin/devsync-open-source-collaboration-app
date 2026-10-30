import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../projects/models/project_model.dart';
import '../../../requests/presentation/collaboration_request_flow.dart';
import '../../domain/entities/match_item.dart';

class CollaborationAction extends StatelessWidget {
  const CollaborationAction({
    super.key,
    required this.match,
    this.maintainerName = 'Karim',
  });

  final MatchItem match;
  final String maintainerName;

  Future<void> _requestToCollaborate(BuildContext context) {
    return presentCollaborationRequestFlow(
      context,
      projectName: match.projectName,
      maintainerName: maintainerName,
      initials: initialsFromTitle(match.projectName),
      matchPercent: match.score.round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    // Opaque fill required: with [Scaffold.extendBody] a transparent bar
    // shows the Android window (black) behind the route.
    return Material(
      color: ds.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppSpacing.buttonHeight,
                height: AppSpacing.buttonHeight,
                child: Material(
                  color: ds.surfaceAlt,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: const Center(
                      child: DsIcon(AppIcons.close, size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: DsButton(
                  label: 'Request to collaborate',
                  icon: AppIcons.requests,
                  onPressed: () => _requestToCollaborate(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class ProjectWorkspaceSheet {
  static Future<void> show(
    BuildContext context, {
    required String repositoryUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ds.surface,
      showDragHandle: true,
      builder: (sheetContext) =>
          _ProjectWorkspaceSheet(repositoryUrl: repositoryUrl),
    );
  }
}

class _ProjectWorkspaceSheet extends StatelessWidget {
  const _ProjectWorkspaceSheet({required this.repositoryUrl});

  final String repositoryUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Project workspace',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            repositoryUrl,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: context.ds.textMuted),
          ),
          const SizedBox(height: AppSpacing.xl),
          DsButton(
            label: 'Copy repository link',
            icon: AppIcons.github,
            onPressed: () => _copyRepositoryLink(context),
          ),
        ],
      ),
    );
  }

  Future<void> _copyRepositoryLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    try {
      await Clipboard.setData(ClipboardData(text: repositoryUrl));
      if (!context.mounted) return;
      Navigator.of(context).pop();
      messenger?.showSnackBar(
        const SnackBar(content: Text('Repository link copied')),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger?.showSnackBar(
        const SnackBar(content: Text('Could not copy repository link')),
      );
    }
  }
}
