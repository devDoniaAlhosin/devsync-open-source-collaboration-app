import 'package:flutter/material.dart';

/// Brand constants + semantic palettes.
///
/// **Rule:** UI chrome (backgrounds, borders, body/muted text) must come from
/// [DevSyncPalette.of] — never from the light-only aliases below — so light and
/// dark stay readable. Use raw [AppColors] only for brand accents and intentional
/// dark panels (heroes, project marks).
abstract final class AppColors {
  // Shared accent (same in both themes)
  static const Color teal = Color(0xFF2EE0C8);
  static const Color onTeal = Color(0xFF0E2624);
  static const Color forest = Color(0xFF0E2624);
  static const Color mint = Color(0xFFE8F5F2);

  // Light theme tokens
  static const Color lightBackground = Color(0xFFF7F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF0EDE6);
  static const Color lightBorder = Color(0xFFE2DDD3);
  static const Color lightText = Color(0xFF0E2624);
  static const Color lightMuted = Color(0xFF5C6B66);

  /// Link / eyebrow accent (prototype `--accent-text`, not bright teal).
  static const Color lightAccentText = Color(0xFF087C71);
  static const Color lightCanvas = Color(0xFFEDE9E0);
  static const Color lightDanger = Color(0xFFC8372D);
  static const Color lightSplash = Color(0xFFF7F5F0);

  // Dark theme / intentional dark panels
  static const Color darkBackground = Color(0xFF0E2624);
  static const Color darkSurface = Color(0xFF153532);
  static const Color darkSurfaceAlt = Color(0xFF1A403C);
  static const Color darkBorder = Color(0xFF1F4A45);
  static const Color darkText = Color(0xFFE8F5F2);
  static const Color darkMuted = Color(0xFF9FC4BD);
  static const Color darkCanvas = Color(0xFF071816);
  static const Color darkDanger = Color(0xFFFF8A7E);
  static const Color glow = Color(0x212EE0C8);

  static const Color onMint = Color(0xFF2C5C56);
  static const Color onProTeal = Color(0xFF14423D);
  static const Color success = teal;

  /// Launch / Welcome open screen (matches [DsSplash]).
  static const LinearGradient launchGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A1F1D),
      forest,
      Color(0xFF123F3A),
      Color(0xFF0E2624),
    ],
    stops: [0.0, 0.35, 0.72, 1.0],
  );
}

/// Brightness-aware UI colors. Prefer `context.ds` / [DevSyncPalette.of].
@immutable
class DevSyncPalette extends ThemeExtension<DevSyncPalette> {
  const DevSyncPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.accentText,
    required this.danger,
    required this.canvas,
    required this.isDark,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color accentText;
  final Color danger;
  final Color canvas;
  final bool isDark;

  /// Convenience aliases used by widgets.
  Color get line => border;
  Color get muted => textMuted;

  static const light = DevSyncPalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceAlt: AppColors.lightSurfaceAlt,
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightText,
    textMuted: AppColors.lightMuted,
    accentText: AppColors.lightAccentText,
    danger: AppColors.lightDanger,
    canvas: AppColors.lightCanvas,
    isDark: false,
  );

  static const dark = DevSyncPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceAlt: AppColors.darkSurfaceAlt,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkText,
    textMuted: AppColors.darkMuted,
    accentText: AppColors.teal,
    danger: AppColors.darkDanger,
    canvas: AppColors.darkCanvas,
    isDark: true,
  );

  static DevSyncPalette of(BuildContext context) {
    return Theme.of(context).extension<DevSyncPalette>() ??
        (Theme.of(context).brightness == Brightness.dark
            ? DevSyncPalette.dark
            : DevSyncPalette.light);
  }

  @override
  DevSyncPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? border,
    Color? textPrimary,
    Color? textMuted,
    Color? accentText,
    Color? danger,
    Color? canvas,
    bool? isDark,
  }) {
    return DevSyncPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      accentText: accentText ?? this.accentText,
      danger: danger ?? this.danger,
      canvas: canvas ?? this.canvas,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  DevSyncPalette lerp(ThemeExtension<DevSyncPalette>? other, double t) {
    if (other is! DevSyncPalette) return this;
    return DevSyncPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension DevSyncThemeX on BuildContext {
  DevSyncPalette get ds => DevSyncPalette.of(this);
}
