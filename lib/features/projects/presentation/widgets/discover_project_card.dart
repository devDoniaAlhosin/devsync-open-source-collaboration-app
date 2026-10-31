import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/project.dart';
import '../../project_layout.dart';
import 'match_badge.dart';
import 'project_action_button.dart';
import 'project_avatar.dart';
import 'tech_tag.dart';

class DiscoverProjectCard extends StatefulWidget {
  const DiscoverProjectCard({
    required this.project,
    required this.requested,
    required this.onTap,
    required this.onRequest,
    super.key,
  });

  final Project project;
  final bool requested;
  final VoidCallback onTap;
  final VoidCallback onRequest;

  @override
  State<DiscoverProjectCard> createState() => _DiscoverProjectCardState();
}

class _DiscoverProjectCardState extends State<DiscoverProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: context.ds.surface.withValues(alpha: _hovered ? 0.92 : 0.78),
          borderRadius: BorderRadius.circular(ProjectLayout.cardRadius),
          border: Border.all(
            color: _hovered
                ? AppColors.teal.withValues(alpha: 0.36)
                : context.ds.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.28 : 0.14),
              blurRadius: _hovered ? 28 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(ProjectLayout.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProjectAvatar(
                        initials: widget.project.initials,
                        size: 50,
                        highlighted: _hovered,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.project.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  AppIcons.atSign,
                                  size: 12,
                                  color: context.ds.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    widget.project.cleanGithubUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: context.ds.textMuted,
                                          fontSize: 11.5,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      MatchBadge(percentage: widget.project.matchPercentage),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.project.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.ds.textPrimary.withValues(alpha: 0.82),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final skill in widget.project.techStack)
                        TechTag(label: skill, compact: true),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final button = SizedBox(
                        height: 48,
                        child: ProjectActionButton(
                          label: widget.requested
                              ? 'Request sent'
                              : 'Request to join',
                          icon: widget.requested ? AppIcons.success : null,
                          variant: widget.requested
                              ? ProjectActionButtonVariant.secondary
                              : ProjectActionButtonVariant.primary,
                          expand: false,
                          compact: true,
                          onPressed: widget.requested ? null : widget.onRequest,
                        ),
                      );
                      final meta = Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.users,
                            size: 16,
                            color: context.ds.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${widget.project.requiredContributors} contributors',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.ds.textMuted,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                        ],
                      );

                      if (constraints.maxWidth < 300) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            meta,
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 48,
                              child: ProjectActionButton(
                                label: widget.requested
                                    ? 'Request sent'
                                    : 'Request to join',
                                icon: widget.requested
                                    ? AppIcons.success
                                    : null,
                                variant: widget.requested
                                    ? ProjectActionButtonVariant.secondary
                                    : ProjectActionButtonVariant.primary,
                                compact: true,
                                onPressed: widget.requested
                                    ? null
                                    : widget.onRequest,
                              ),
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: meta),
                          const SizedBox(width: 12),
                          button,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
