import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../../requests/presentation/collaboration_request_flow.dart';
import '../../domain/entities/match_item.dart';
import '../widgets/project_details_chrome.dart';
import '../widgets/project_details_content.dart';

class MatchProjectDetailsArguments {
  final MatchItem match;

  final List<String> currentUserSkills;
  const MatchProjectDetailsArguments({
    required this.match,
    this.currentUserSkills = const [],
  });
}

/// Match-deck project details (distinct from projects feature ProjectDetailsScreen).
class MatchProjectDetailsScreen extends StatelessWidget {
  final MatchProjectDetailsArguments? arguments;

  const MatchProjectDetailsScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final details = arguments;
    final hasWorkspace =
        details != null && details.match.githubUrl.trim().isNotEmpty;

    return Scaffold(
      extendBody: details != null,
      appBar: DsAppBar(
        title: 'Project details',
        eyebrow: 'WORKSPACE',
        onNotifications: () {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        },
      ),
      body: details == null
          ? const DsEmptyState(
              icon: AppIcons.projects,
              title: 'No project selected',
              message:
                  'Open project details from a match to see its workspace.',
            )
          : ProjectDetailsContent(
              match: details.match,
              currentUserSkills: details.currentUserSkills,
            ),
      bottomNavigationBar: details == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    if (hasWorkspace) ...[
                      Expanded(
                        child: DsButton(
                          label: 'Preview',
                          icon: AppIcons.forward,
                          variant: DsButtonVariant.quiet,
                          onPressed: () => ProjectWorkspaceSheet.show(
                            context,
                            repositoryUrl: details.match.githubUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      child: DsButton(
                        label: 'Request',
                        onPressed: () => presentCollaborationRequestFlow(
                          context,
                          projectName: details.match.projectName,
                          maintainerName: 'Project maintainer',
                          initials: details.match.projectName
                              .split(RegExp(r'[/\s\-]'))
                              .where((p) => p.isNotEmpty)
                              .take(2)
                              .map((p) => p[0].toUpperCase())
                              .join(),
                          matchPercent: details.match.score.round(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
