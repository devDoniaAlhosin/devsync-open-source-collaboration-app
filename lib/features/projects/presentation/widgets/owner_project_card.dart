import 'package:flutter/material.dart';

import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/ds_icon_button.dart';
import '../../domain/entities/project.dart';
import '../../project_layout.dart';
import 'project_avatar.dart';
import 'sparkline_chart.dart';

class OwnerProjectCard extends StatefulWidget {
  const OwnerProjectCard({
    required this.project,
    required this.weeklyViews,
    required this.onTap,
    required this.onEdit,
    super.key,
  });

  final Project project;
  final List<double> weeklyViews;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  State<OwnerProjectCard> createState() => _OwnerProjectCardState();
}

class _OwnerProjectCardState extends State<OwnerProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final hasRequests = widget.project.requestsCount > 0;

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
                ? AppColors.teal.withValues(alpha: 0.30)
                : context.ds.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.26 : 0.12),
              blurRadius: _hovered ? 26 : 16,
              offset: const Offset(0, 9),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 17),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.project.contributorsLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: context.ds.textMuted,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      DsIconButton(
                        icon: AppIcons.edit,
                        tooltip: 'Edit project',
                        onPressed: widget.onEdit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SparklineChart(values: widget.weeklyViews),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Views this week',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.ds.textMuted,
                                fontSize: 11.5,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (hasRequests)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${widget.project.requestsCount} new requests',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.onTeal,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0,
                                ),
                          ),
                        )
                      else
                        Text(
                          'No new requests',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.ds.textMuted,
                                fontSize: 11.5,
                              ),
                        ),
                    ],
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
