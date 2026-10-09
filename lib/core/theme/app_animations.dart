import 'package:flutter/material.dart';

/// Standard durations and curves for key-screen motion (animation kit).
///
/// Feature owners should reuse these instead of inventing per-screen timings.
/// Bishay owns key-screen animation polish on top of this kit.
abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration page = Duration(milliseconds: 300);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeInOutCubic;
  static const Curve decelerate = Curves.decelerate;

  /// Press feedback used by shared buttons (brand guide: scale 0.97).
  static const double pressScale = 0.97;
}
