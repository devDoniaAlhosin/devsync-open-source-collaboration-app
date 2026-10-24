import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_text_field.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_meter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final email = _email.text.trim();
    setState(() {
      _error = isValidEmail(email) ? null : 'Enter a valid email address';
    });
    if (_error != null) return;

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushNamed(
      AppRoutes.verifyCode,
      arguments: {'email': email, 'from': 'reset'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Recover account',
      onThemeToggle: DevSyncApp.toggleTheme,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthInlineHeading(
            orbIcon: AppIcons.mail,
            eyebrow: 'Account recovery',
            title: 'Forgot your password?',
            body:
                "Enter your email and we'll guide you through resetting your password.",
          ),
          const SizedBox(height: AppSpacing.xl),
          DsTextField(
            label: 'Email address',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            errorText: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Continue',
            icon: AppIcons.forward,
            isLoading: _loading,
            onPressed: _loading ? null : _continue,
          ),
          const SizedBox(height: AppSpacing.md),
          const AuthNote(
            title: 'Secure recovery.',
            message:
                'For the demo, continue to the code screen. Real emails need a backend.',
          ),
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Back to sign in',
            variant: DsButtonVariant.quiet,
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}
