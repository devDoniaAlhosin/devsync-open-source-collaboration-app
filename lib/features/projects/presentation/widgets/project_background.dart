import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Page chrome for project screens — same solid [DevSyncPalette.background]
/// as the rest of the app.
class ProjectBackground extends StatelessWidget {
  const ProjectBackground({
    required this.child,
    this.showStars = true,
    super.key,
  });

  final Widget child;

  /// Kept for call-site compatibility; stars are no longer drawn.
  final bool showStars;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.ds.background,
      child: child,
    );
  }
}
