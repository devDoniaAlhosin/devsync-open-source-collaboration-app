import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

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
    DsLogoVariant.icon => AppAssets.icon,
  };

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'DevSync',
    );
  }
}
