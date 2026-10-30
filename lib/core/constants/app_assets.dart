/// Central paths for bundled brand images.
///
/// Prefer [AppLogo] / these constants over hard-coded asset strings.
abstract final class AppAssets {
  static const String _png = 'assets/brand/png';
  static const String _svg = 'assets/brand/svg';

  static const String logoTeal = '$_png/devsync-logo-teal.png';
  static const String logoLight = '$_png/devsync-logo-light.png';
  static const String logoDark = '$_png/devsync-logo-dark.png';

  static const String appIcon = '$_png/devsync-app-icon.png';
  static const String appIconTeal = '$_png/devsync-app-icon-teal.png';

  static const String icon = '$_png/devsync-icon.png';
  static const String iconMint = '$_png/devsync-icon-mint.png';
  static const String iconForest = '$_png/devsync-icon-forest.png';

  /// Vector mark (recolor with [ColorFilter] / `flutter_svg`).
  static const String iconSvg = '$_svg/devsync-icon.svg';
  static const String iconForestSvg = '$_svg/devsync-icon-forest.svg';
}
