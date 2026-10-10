import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Four-segment password meter (prototype `.pw`).
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.password});

  final String password;

  int get score {
    var s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'\d').hasMatch(password)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) s++;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final active = score;
    final ds = context.ds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 5,
                margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                decoration: BoxDecoration(
                  color: i < active ? AppColors.teal : ds.border,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 7),
        Text(
          '8+ characters, uppercase, number and symbol.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ds.textMuted,
              ),
        ),
      ],
    );
  }
}

bool isStrongPassword(String password) {
  return password.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(password) &&
      RegExp(r'\d').hasMatch(password) &&
      RegExp(r'[^A-Za-z0-9]').hasMatch(password);
}

bool isValidEmail(String email) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
}
