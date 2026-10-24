import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../shell/home_shell_screen.dart';
import '../cubit/auth_cubit.dart';
import '../pages/verify_email_screen.dart';
import '../pages/welcome_screen.dart';

/// Routes to Home when signed in + verified, otherwise Welcome / verify email.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty || !getIt.isRegistered<AuthCubit>()) {
      return const WelcomeScreen();
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
            AuthSignedOut() => const WelcomeScreen(),
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
void navigateToHome(BuildContext context) {
  Navigator.of(
    context,
  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
}
