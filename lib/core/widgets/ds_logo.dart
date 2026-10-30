import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

enum DsLogoVariant { wordmarkTeal, wordmarkLight, wordmarkDark, appIcon, icon }

/// Brand mark / wordmark from [AppAssets].
class DsLogo extends StatelessWidget {
  const DsLogo({
    super.key,
    this.variant = DsLogoVariant.wordmarkTeal,
    this.height = 40,
    this.color,
  });

  final DsLogoVariant variant;
  final double height;

  /// When set, tints the asset (useful for the monochrome [DsLogoVariant.icon] mark).
  final Color? color;

  String get _asset => switch (variant) {
        DsLogoVariant.wordmarkTeal => AppAssets.logoTeal,
        DsLogoVariant.wordmarkLight => AppAssets.logoLight,
        DsLogoVariant.wordmarkDark => AppAssets.logoDark,
        DsLogoVariant.appIcon => AppAssets.appIconTeal,
        DsLogoVariant.icon => AppAssets.iconMint,
      };

  @override
  Widget build(BuildContext context) {
    final mark = variant == DsLogoVariant.icon;
    final tint = color ?? (mark ? AppColors.teal : null);
    return Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      color: tint,
      colorBlendMode: tint != null ? BlendMode.srcIn : null,
      filterQuality: FilterQuality.high,
      semanticLabel: 'DevSync',
    );
  }
}
