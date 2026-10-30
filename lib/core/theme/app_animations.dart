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

  /// Apple-like tab bar crossfade (opacity only, keep-alive).
  static const Duration tabCrossfade = Duration(milliseconds: 320);

  /// Proto V22 `motion-enter` item duration (`.48s`).
  static const Duration itemEnter = Duration(milliseconds: 480);

  /// Proto V22 item stagger (`45ms`).
  static const Duration itemStagger = Duration(milliseconds: 45);

  /// Prototype `--ease`.
  static const Curve emphasized = Cubic(0.2, 0.8, 0.2, 1);

  /// Proto V22 `dsItemIn` curve (`cubic-bezier(.2,.75,.2,1)`).
  static const Curve itemEnterCurve = Cubic(0.2, 0.75, 0.2, 1);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.decelerate;

  /// iOS-style tab content crossfade.
  static const Curve tabCrossfadeCurve = Curves.easeInOutCubic;

  static const double pressScale = 0.97;
  static const double iconPressScale = 0.92;

  /// Micro-scale at the start of `dsItemIn` / page enter.
  static const double itemEnterScale = 0.97;

  /// Fractional Y offset for page/tab fade+rise (~16px on a phone).
  static const double itemEnterSlide = 0.04;

  /// Stagger between entrance items (`60ms` in prototype gallery rise).
  static const Duration stagger = Duration(milliseconds: 60);
}
