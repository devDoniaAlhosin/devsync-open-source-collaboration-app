import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Decorative login hero panel from the prototype.
class AuthHeroCard extends StatelessWidget {
  const AuthHeroCard({
    super.key,
    this.title = 'Your next contribution starts here.',
    this.subtitle = 'Projects, teammates and tasks in sync.',
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMatch),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF153F3B), Color(0xFF09201F)],
        ),
        border: Border.all(color: const Color(0xFF276258)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.55),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                if (i < 2) const SizedBox(width: 8),
              ],
              const SizedBox(width: 8),
              Text(
                'COMMUNITY ACTIVITY',
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFA9D4CB),
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              color: const Color(0xFFEFFEFB),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFFA9D4CB),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
