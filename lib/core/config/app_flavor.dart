/// Build-time Free / Pro tier (`--dart-define=FLAVOR=pro` or Gradle product flavor).
enum AppFlavor { free, pro }

abstract final class AppFlavorConfig {
  static const _raw = String.fromEnvironment('FLAVOR', defaultValue: 'free');

  static AppFlavor get current =>
      _raw.toLowerCase() == 'pro' ? AppFlavor.pro : AppFlavor.free;

  static bool get isPro => current == AppFlavor.pro;

  static String get label => isPro ? 'DevSync Pro' : 'DevSync Free';
}
