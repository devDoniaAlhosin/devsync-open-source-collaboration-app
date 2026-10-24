import 'package:flutter/animation.dart';

/// Animation kit from the prototype (`cubic-bezier(.2, .8, .2, 1)`).
abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration rise = Duration(milliseconds: 650);
  static const Duration handoff = Duration(milliseconds: 780);
  static const Duration score = Duration(milliseconds: 1100);
  static const Duration page = Duration(milliseconds: 300);

  /// Prototype `--ease`.
  static const Curve emphasized = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.decelerate;

  static const double pressScale = 0.97;
  static const double iconPressScale = 0.92;

  /// Stagger between entrance items (`60ms` in prototype).
  static const Duration stagger = Duration(milliseconds: 60);
}
