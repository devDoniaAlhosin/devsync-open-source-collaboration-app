abstract final class ProjectLayout {
  static const maxWidth = 1120.0;
  static const formWidth = 980.0;
  static const detailsWidth = 860.0;
  static const mobileGutter = 16.0;
  static const desktopGutter = 32.0;
  static const bottomNavSpace = 112.0;
  static const cardRadius = 18.0;
  static const controlRadius = 12.0;

  static double gutterFor(double width) =>
      width >= 760 ? desktopGutter : mobileGutter;
}
