import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProjectAvatar extends StatelessWidget {
  const ProjectAvatar({
    required this.initials,
    this.size = 52,
    this.highlighted = false,
    super.key,
  });

  final String initials;
  final double size;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: highlighted
              ? AppColors.teal.withValues(alpha: 0.45)
              : context.ds.border,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlighted
              ? [AppColors.teal.withValues(alpha: 0.20), context.ds.surfaceAlt]
              : [context.ds.surfaceAlt, context.ds.surfaceAlt],
        ),
        boxShadow: highlighted
            ? [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontSize: size * 0.35,
          height: 1,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: AppColors.teal,
        ),
      ),
    );
  }
}
