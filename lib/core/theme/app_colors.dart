import 'package:flutter/material.dart';

/// DevSync brand palette from the Brand Guide.
///
/// One accent (teal) on a dark forest base. Prefer these tokens over raw
/// [Color] literals so Free/Pro flavors stay consistent.
abstract final class AppColors {
  static const Color teal = Color(0xFF2EE0C8);
  static const Color forest = Color(0xFF0E2624);
  static const Color mint = Color(0xFFE8F5F2);
  static const Color surface = Color(0xFF153532);
  static const Color line = Color(0xFF1F4A45);
  static const Color muted = Color(0xFF9FC4BD);

  /// Dark text on mint backgrounds (logo lockups).
  static const Color onMint = Color(0xFF2C5C56);

  /// Dark text on Pro teal surfaces.
  static const Color onProTeal = Color(0xFF14423D);

  static const Color onTeal = forest;
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = teal;
}
