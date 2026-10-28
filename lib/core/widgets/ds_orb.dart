import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'ds_icon.dart';

/// Gradient icon orb used on recovery / verify screens (prototype `.auth-orb`).
class DsOrb extends StatelessWidget {
  const DsOrb({super.key, required this.icon, this.size = 94});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl + 4),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.teal, Color(0xFF0C756B)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: DsIcon(icon, size: size * 0.38, color: AppColors.forest),
    );
  }
}
