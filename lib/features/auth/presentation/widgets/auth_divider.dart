import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with email'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: ds.textMuted, fontSize: 13);

    return Row(
      children: [
        Expanded(child: Divider(color: ds.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: style),
        ),
        Expanded(child: Divider(color: ds.border)),
      ],
    );
  }
}
