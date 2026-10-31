import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project.dart';
import 'project_avatar.dart';
import 'tech_tag.dart';

class ProjectPreviewCard extends StatelessWidget {
  const ProjectPreviewCard({
    required this.title,
    required this.skills,
    super.key,
  });

  final String title;
  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isEmpty
        ? 'Untitled project'
        : title.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.ds.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.ds.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview in feeds',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.ds.textMuted,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ProjectAvatar(
                initials: initialsFromTitle(displayTitle),
                size: 56,
                highlighted: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'by you',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.ds.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (skills.isEmpty)
            Text(
              'Add skills to preview your tags.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
            )
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final skill in skills.take(5))
                  TechTag(label: skill, compact: true, selected: true),
              ],
            ),
          if (skills.length > 5) ...[
            const SizedBox(height: 8),
            Text(
              '+${skills.length - 5} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: context.ds.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
