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
  });

  final DsLogoVariant variant;
  final double height;

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
    return Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      color: mark ? AppColors.teal : null,
      colorBlendMode: mark ? BlendMode.srcIn : null,
      filterQuality: FilterQuality.high,
      semanticLabel: 'DevSync',
    );
  }
}
