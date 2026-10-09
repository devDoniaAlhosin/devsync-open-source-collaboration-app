/// Spacing, radii, and touch-target tokens shared across the app.
///
/// Design checklist: minimum **48 dp** touch targets (FR-24 / NFR-13).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 12;
  static const double radiusMd = 14;
  static const double radiusLg = 28;
  static const double radiusPill = 99;

  /// Minimum interactive control size (Material / a11y).
  static const double minTouchTarget = 48;

  static const double screenPadding = lg;
}
