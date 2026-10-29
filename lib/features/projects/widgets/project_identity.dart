import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/project_model.dart';
import '../models/project_stats.dart';
import 'project_avatar.dart';

class ProjectIdentity extends StatelessWidget {
  const ProjectIdentity({
    required this.project,
    required this.stats,
    super.key,
  });

  final ProjectModel project;
  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ProjectAvatar(initials: project.initials, size: 62, highlighted: true),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.title,
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                'by ${stats.ownerName}  ·  ${stats.updatedLabel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.ds.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
