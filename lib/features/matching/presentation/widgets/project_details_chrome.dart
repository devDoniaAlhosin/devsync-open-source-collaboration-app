import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../../domain/entities/match_item.dart';

class ProjectDetailsBackButton extends StatelessWidget {
  const ProjectDetailsBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) =>
      DsIconButton(icon: AppIcons.back, tooltip: 'Back', onPressed: onPressed);
}

class ProjectDetailsHeader extends StatelessWidget {
  const ProjectDetailsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORKSPACE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.ds.accentText,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        Text(
          'Project details',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class CollaborationAction extends StatelessWidget {
  const CollaborationAction({super.key, required this.match});

  final MatchItem match;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.ds.background,
        border: Border(top: BorderSide(color: context.ds.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.md,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: DsButton(
            label: 'Request to collaborate',
            icon: AppIcons.requests,
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.requests, arguments: match),
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
