import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Step progress for multi-step auth (prototype `.auth-progress`).
class AuthProgressBar extends StatelessWidget {
  const AuthProgressBar({super.key, required this.step, this.total = 3});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;

    return Row(
      children: List.generate(total, (i) {
        final on = i < step;
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: i == total - 1 ? 0 : 5),
            decoration: BoxDecoration(
              color: on ? AppColors.teal : ds.border,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
      }),
    );
  }
}
