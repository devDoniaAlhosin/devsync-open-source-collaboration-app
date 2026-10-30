import 'package:flutter/material.dart';

import '../theme/app_animations.dart';

/// Fade + slight rise (+ micro-scale) matching prototype `dsItemIn`.
///
/// Use as [AnimatedSwitcher.transitionBuilder], or via [DsFadePageRoute].
Widget dsFadeRiseTransition(
  Widget child,
  Animation<double> animation, {
  double slide = AppAnimations.itemEnterSlide,
  double beginScale = AppAnimations.itemEnterScale,
  Curve curve = AppAnimations.itemEnterCurve,
}) {
  final curved = CurvedAnimation(parent: animation, curve: curve);
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, slide),
        end: Offset.zero,
      ).animate(curved),
      child: ScaleTransition(
        scale: Tween<double>(begin: beginScale, end: 1).animate(curved),
        child: child,
      ),
    ),
  );
}

/// [AnimatedSwitcher] transition that mirrors proto screen-enter motion.
Widget dsFadeRiseSwitch(Widget child, Animation<double> animation) {
  return dsFadeRiseTransition(child, animation);
}

/// Page route with fade + rise instead of the default Material slide.
///
/// Incoming page fades/rises in over the previous route (`opaque: false`).
/// When another route is pushed on top, this page soft-fades out via
/// [secondaryAnimation].
class DsFadePageRoute<T> extends PageRouteBuilder<T> {
  DsFadePageRoute({
    required WidgetBuilder builder,
    super.settings,
    Duration? duration,
    Duration? reverseDuration,
    super.fullscreenDialog,
    super.maintainState,
  }) : super(
         opaque: false,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionDuration: duration ?? AppAnimations.itemEnter,
         reverseTransitionDuration: reverseDuration ?? AppAnimations.page,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           if (MediaQuery.disableAnimationsOf(context) ||
               WidgetsBinding.instance.disableAnimations) {
             return child;
           }
           final entering = dsFadeRiseTransition(child, animation);
           return FadeTransition(
             opacity: Tween<double>(begin: 1, end: 0).animate(
               CurvedAnimation(
                 parent: secondaryAnimation,
                 curve: AppAnimations.itemEnterCurve,
               ),
             ),
             child: entering,
           );
         },
       );
}
