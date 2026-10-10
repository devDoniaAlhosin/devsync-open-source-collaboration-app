import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_card.dart';
import '../../core/widgets/ds_chip.dart';
import '../../core/widgets/ds_info_row.dart';
import '../../core/widgets/ds_text_field.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_social_buttons.dart';
import 'widgets/password_strength_meter.dart';

class CodeSignInScreen extends StatefulWidget {
  const CodeSignInScreen({super.key});

  @override
  State<CodeSignInScreen> createState() => _CodeSignInScreenState();
}

class _CodeSignInScreenState extends State<CodeSignInScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
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
      arguments: {'email': email, 'from': 'code'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Passwordless sign in',
      onThemeToggle: DevSyncApp.toggleTheme,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: DsChip(
              label: '1 · Verify your email',
              variant: DsChipVariant.success,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthInlineHeading(
            orbIcon: AppIcons.shield,
            eyebrow: 'No password needed',
            title: 'Sign in with a code.',
            body:
                "Enter your email. We'll send a six-digit verification code.",
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
            label: 'Email me a sign-in code',
            icon: AppIcons.forward,
            isLoading: _loading,
            onPressed: _loading ? null : _sendCode,
          ),
          const SizedBox(height: AppSpacing.xl),
          const DsCard(
            child: Column(
              children: [
                DsInfoRow(
                  icon: AppIcons.shield,
                  title: 'Secure and simple',
                  subtitle: 'One-time codes expire after 10 minutes',
                  showDivider: true,
                ),
                DsInfoRow(
                  icon: AppIcons.success,
                  title: 'No password to remember',
                  subtitle: 'Access your projects in seconds',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthTextLink(
                label: 'Use password instead',
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login),
              ),
              Text(' · ', style: Theme.of(context).textTheme.bodySmall),
              AuthTextLink(
                label: 'Forgot password?',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
