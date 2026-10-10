import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthEyebrow extends StatelessWidget {
  const AuthEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.teal,
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.8,
          ),
    );
  }
}
