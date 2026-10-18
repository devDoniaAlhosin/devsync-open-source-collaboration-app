import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import 'data/auth_service.dart';
import 'widgets/auth_scaffold.dart';

/// Waiting screen after a passwordless email link was sent.
class EmailLinkSentScreen extends StatefulWidget {
  const EmailLinkSentScreen({super.key, this.email});

  final String? email;

  @override
  State<EmailLinkSentScreen> createState() => _EmailLinkSentScreenState();
}

class _EmailLinkSentScreenState extends State<EmailLinkSentScreen> {
  final _auth = AuthService();
  bool _resending = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
    if (_email == null) {
      _auth.pendingEmailLinkAddress().then((value) {
        if (mounted) setState(() => _email = value);
      });
    }
  }

  Future<void> _resend() async {
    final email = _email;
    if (email == null || email.isEmpty) return;
    setState(() => _resending = true);
    try {
      await _auth.sendSignInLinkToEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign-in link sent again')),
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

  @override
  Widget build(BuildContext context) {
    final email = _email ?? 'your email';

    return AuthScaffold(
      title: 'Check your email',
      onThemeToggle: DevSyncApp.toggleTheme,
      onBack: () => Navigator.of(context).pushReplacementNamed(
        AppRoutes.codeSignIn,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthInlineHeading(
            orbIcon: AppIcons.mail,
            eyebrow: 'One last step',
            title: 'Open your inbox.',
            body:
                'We sent a sign-in link to $email. Tap it on this device to finish signing in.',
          ),
          const SizedBox(height: AppSpacing.xl),
          DsButton(
            label: 'Resend sign-in link',
            variant: DsButtonVariant.secondary,
            isLoading: _resending,
            onPressed: _resending ? null : _resend,
          ),
          const SizedBox(height: AppSpacing.md),
          DsButton(
            label: 'Use password instead',
            variant: DsButtonVariant.quiet,
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AuthNote(
            title: 'Tip:',
            message:
                'Keep this app open. After you tap the link, DevSync will sign you in automatically. Check spam if you do not see the email.',
          ),
        ],
      ),
    );
  }
}
