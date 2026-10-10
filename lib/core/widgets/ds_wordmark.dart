import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Text lockup: Dev + Sync (teal). Defaults follow the active light/dark palette.
class DsWordmark extends StatelessWidget {
  const DsWordmark({
    super.key,
    this.fontSize = 30,
    this.syncColor,
    this.devColor,
  });

  final double fontSize;
  final Color? syncColor;
  final Color? devColor;

  @override
  Widget build(BuildContext context) {
    final palette = DevSyncPalette.of(context);
    final base = Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.9,
          height: 1,
        );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(
            text: 'Dev',
            style: TextStyle(color: devColor ?? palette.textPrimary),
          ),
          TextSpan(
            text: 'Sync',
            style: TextStyle(color: syncColor ?? AppColors.teal),
          ),
        ],
      ),
      semanticsLabel: 'DevSync',
    );
  }
}
