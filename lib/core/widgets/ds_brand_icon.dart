import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// DevSync SVG mark for chrome (app bars, empty states).
///
/// Defaults to [AppAssets.iconForestSvg] tinted with brand teal so it reads
/// on light and dark surfaces.
class DsBrandIcon extends StatelessWidget {
  const DsBrandIcon({
    super.key,
    this.size = 28,
    this.color,
    this.asset = AppAssets.iconForestSvg,
  });

  final double size;
  final Color? color;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.teal;
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
      semanticsLabel: 'DevSync',
    );
  }
}
