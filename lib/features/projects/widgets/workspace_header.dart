import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ds_icon_button.dart';
import '../project_layout.dart';

class WorkspaceHeader extends StatelessWidget {
  const WorkspaceHeader({
    required this.title,
    required this.onBack,
    required this.maxContentWidth,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final double maxContentWidth;
  final Widget? trailing;

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
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Row(
                  children: [
                    DsIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onPressed: onBack,
                      tooltip: 'Back',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'WORKSPACE',
                            style: Theme.of(context).textTheme.labelSmall,
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
                    if (trailing != null) ...[
                      const SizedBox(width: 12),
                      trailing!,
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
