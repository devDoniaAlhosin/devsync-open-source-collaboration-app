import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Shared [ThemeData]. **Light is the default** app theme.
abstract final class AppTheme {
  /// Splash / loading window colors (native + Flutter first frame).
  static const Color splashBackground = Color(0xFFC5E6DE);
  static const Color splashIconBackground = AppColors.forest;

  static ThemeData light() {
    final palette = DevSyncPalette.light;
    final textTheme = AppTypography.textTheme(
      color: palette.textPrimary,
      muted: palette.textMuted,
    );

    return _base(
      brightness: Brightness.light,
      palette: palette,
      textTheme: textTheme,
      overlay: SystemUiOverlayStyle.dark,
    );
  }

  static ThemeData dark() {
    final palette = DevSyncPalette.dark;
    final textTheme = AppTypography.textTheme(
      color: palette.textPrimary,
      muted: palette.textMuted,
    );

    return _base(
      brightness: Brightness.dark,
      palette: palette,
      textTheme: textTheme,
      overlay: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData _base({
    required Brightness brightness,
    required DevSyncPalette palette,
    required TextTheme textTheme,
    required SystemUiOverlayStyle overlay,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.teal,
      onPrimary: AppColors.onTeal,
      secondary: AppColors.teal,
      onSecondary: AppColors.onTeal,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      error: palette.danger,
      onError: brightness == Brightness.light ? Colors.white : AppColors.forest,
      outline: palette.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlay,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          side: BorderSide(color: palette.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.teal;
          return palette.surface;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.onTeal),
        side: BorderSide(color: palette.border, width: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: palette.textMuted),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: palette.accentText,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: palette.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: palette.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.teal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: BorderSide(color: palette.danger, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceAlt,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.teal,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.onTeal,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: AppColors.teal,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.onTeal;
          return palette.textPrimary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.teal;
          return palette.border;
        }),
      ),
    );
  }
}
