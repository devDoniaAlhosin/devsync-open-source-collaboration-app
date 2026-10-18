import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import 'data/auth_service.dart';
import 'widgets/auth_gate.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_social_buttons.dart';

/// After email/password signup: wait until Firebase email link is confirmed.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = AuthService();
  bool _loading = false;
  bool _resending = false;

  String get _email =>
      widget.email ??
      _auth.currentUser?.email ??
      'your email';

  Future<void> _resend() async {
    setState(() => _resending = true);
    try {
      await _auth.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.messageFor(e))),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _checkVerified() async {
    setState(() => _loading = true);
    try {
      final ok = await _auth.reloadAndIsEmailVerified();
      if (!mounted) return;
      if (ok) {
        navigateToHome(context);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not verified yet. Open the link in your email first.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.messageFor(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useAnotherAccount() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verify email',
      showBack: false,
      onThemeToggle: DevSyncApp.toggleTheme,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthInlineHeading(
            orbIcon: AppIcons.mail,
            eyebrow: 'One last step',
            title: 'Confirm your email.',
            body:
                'We sent a verification link to $_email. Open it, then come back and continue.',
          ),
          const SizedBox(height: AppSpacing.xl),
          DsButton(
            label: 'I verified — continue',
            icon: AppIcons.forward,
            isLoading: _loading,
            onPressed: _loading ? null : _checkVerified,
          ),
          const SizedBox(height: AppSpacing.md),
          DsButton(
            label: 'Resend verification email',
            variant: DsButtonVariant.secondary,
            isLoading: _resending,
            onPressed: _resending ? null : _resend,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: AuthTextLink(
              label: 'Use a different account',
              onPressed: _useAnotherAccount,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AuthNote(
            title: 'Tip:',
            message:
                'Check spam if you do not see the email. The link expires after a while — tap Resend if needed.',
          ),
        ],
      ),
    );
  }
}
