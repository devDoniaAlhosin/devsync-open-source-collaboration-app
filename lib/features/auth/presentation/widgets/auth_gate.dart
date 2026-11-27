import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/presentation/screens/home_shell_screen.dart';
import '../cubit/auth_cubit.dart';
import '../screens/intro_screen.dart';
import '../screens/verify_email_screen.dart';

/// Routes to Home when signed in + verified, otherwise Intro / verify email.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty || !getIt.isRegistered<AuthCubit>()) {
      return const IntroScreen();
    }

    return BlocProvider.value(
      value: getIt<AuthCubit>(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return switch (state) {
            AuthInitial() => const Scaffold(
              backgroundColor: AppColors.forest,
              body: DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.launchGradient),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              ),
            ),
            AuthSignedOut() => const IntroScreen(),
            AuthNeedsVerification(:final user) => VerifyEmailScreen(
              email: user.email,
            ),
            AuthAuthenticated() => const HomeShellScreen(),
          };
        },
      ),
    );
  }
}

/// Shared helper for auth screens after a successful credential exchange.
void navigateToHome(BuildContext context, {int tabIndex = 0}) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.home,
    (route) => false,
    arguments: tabIndex,
  );
}

/// Optional setup hint only. Prefer [navigateToHome] after auth so users can
/// explore, add projects, and connect GitHub when they choose.
void navigateToOnboarding(BuildContext context) {
  Navigator.of(
    context,
  ).pushNamedAndRemoveUntil(AppRoutes.choosePath, (route) => false);
}
