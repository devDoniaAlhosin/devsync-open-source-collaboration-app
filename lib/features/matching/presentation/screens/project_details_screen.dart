import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/widgets/ds_app_bar.dart';
import '../../../../core/widgets/ds_empty_state.dart';
import '../../domain/entities/match_item.dart';
import '../widgets/project_details_chrome.dart';
import '../widgets/project_details_content.dart';

class ProjectDetailsArguments {
  final MatchItem match;

  final List<String> currentUserSkills;
  const ProjectDetailsArguments({
    required this.match,
    this.currentUserSkills = const [],
  });
}

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectDetailsArguments? arguments;

  const ProjectDetailsScreen({super.key, this.arguments});

  @override
  Widget build(BuildContext context) {
    final details = arguments;
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
              onPreviewWorkspace: () => ProjectWorkspaceSheet.show(
                context,
                repositoryUrl: details.match.githubUrl,
              ),
            ),
      bottomNavigationBar: details == null
          ? null
          : CollaborationAction(match: details.match),
    );
  }
}
