import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../shell/home_shell_screen.dart';
import '../data/auth_service.dart';
import '../verify_email_screen.dart';
import '../welcome_screen.dart';

/// Routes to Home when signed in + verified, otherwise Welcome / verify email.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) {
      return const WelcomeScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const WelcomeScreen();
        }
        if (AuthService().needsEmailVerification) {
          return VerifyEmailScreen(email: user.email);
        }
        return const HomeShellScreen();
      },
    );
  }
}

/// Shared helper for auth screens after a successful credential exchange.
void navigateToHome(BuildContext context) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.home,
    (route) => false,
  );
}
