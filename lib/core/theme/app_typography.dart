import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography: Bricolage Grotesque (headings) + Figtree (body / UI).
abstract final class AppTypography {
  static TextTheme textTheme({
    Color? color,
    Color? muted,
  }) {
    final base = color ?? AppColors.lightText;
    final soft = muted ?? AppColors.lightMuted;

    final heading = GoogleFonts.bricolageGrotesque;
    final body = GoogleFonts.figtree;

    return TextTheme(
      displayLarge: heading(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.1,
        color: base,
      ),
      displayMedium: heading(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.64,
        height: 1.1,
        color: base,
      ),
      headlineLarge: heading(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.56,
        height: 1.15,
        color: base,
      ),
      headlineMedium: heading(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.44,
        height: 1.2,
        color: base,
      ),
      headlineSmall: heading(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.25,
        color: base,
      ),
      titleLarge: body(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleMedium: body(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleSmall: body(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      bodyLarge: body(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: base,
      ),
      bodyMedium: body(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: base,
      ),
      bodySmall: body(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: soft,
      ),
      labelLarge: body(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      labelMedium: body(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: soft,
      ),
      labelSmall: body(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: soft,
      ),
    );
  }
}
