import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ds_icon_button.dart';
import '../project_layout.dart';

class ProjectTopBar extends StatelessWidget {
  const ProjectTopBar({
    required this.eyebrow,
    required this.title,
    this.leadingIcon = Icons.menu_rounded,
    this.onLeadingPressed,
    this.actions = const [],
    super.key,
  });

  final String eyebrow;
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onLeadingPressed;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.ds.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gutter = ProjectLayout.gutterFor(constraints.maxWidth);
          return Padding(
            padding: EdgeInsets.fromLTRB(gutter, 10, gutter, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ProjectLayout.maxWidth,
                ),
                child: Row(
                  children: [
                    DsIconButton(
                      icon: leadingIcon,
                      onPressed: onLeadingPressed,
                      tooltip: 'Open menu',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            eyebrow.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (actions.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      for (var i = 0; i < actions.length; i++) ...[
                        actions[i],
                        if (i != actions.length - 1) const SizedBox(width: 8),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
