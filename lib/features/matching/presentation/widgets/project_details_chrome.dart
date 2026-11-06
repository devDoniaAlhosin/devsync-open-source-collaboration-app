import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';

/// Shows the actual repository URL supplied by the matching backend.
abstract final class ProjectWorkspaceSheet {
  static Future<void> show(
    BuildContext context, {
    required String repositoryUrl,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.ds.surface,
      showDragHandle: true,
      builder: (_) => _ProjectWorkspaceSheet(repositoryUrl: repositoryUrl),
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
            'Repository link',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          SelectableText(
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
