import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_card.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_info_row.dart';
import '../../core/widgets/ds_text_field.dart';
import 'data/auth_service.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_step_badge.dart';
import 'widgets/password_strength_meter.dart';

class CodeSignInScreen extends StatefulWidget {
  const CodeSignInScreen({super.key});

  @override
  State<CodeSignInScreen> createState() => _CodeSignInScreenState();
}

class _CodeSignInScreenState extends State<CodeSignInScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final email = _email.text.trim();
    setState(() {
      _error = isValidEmail(email) ? null : 'Enter a valid email address';
    });
    if (_error != null) return;

    setState(() => _loading = true);
    try {
      await _auth.sendSignInLinkToEmail(email);
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.emailLinkSent,
        arguments: {'email': email},
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AuthService.messageFor(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    final textTheme = Theme.of(context).textTheme;

    return AuthScaffold(
      title: 'Sign in with code',
      onThemeToggle: DevSyncApp.toggleTheme,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthStepBadge(
            step: 1,
            label: 'Verify your email · Secure sign-in',
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthInlineHeading(
            orbIcon: AppIcons.shield,
            eyebrow: 'No password needed',
            title: 'Sign in with a link.',
            body:
                "Enter your email. We'll send a one-tap sign-in link — no password required.",
          ),
          const SizedBox(height: AppSpacing.xl),
          DsTextField(
            label: 'Email address',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            errorText: _error,
            onSubmitted: (_) => _sendLink(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Email me a sign-in link',
            icon: AppIcons.forward,
            isLoading: _loading,
            onPressed: _loading ? null : _sendLink,
          ),
          const SizedBox(height: AppSpacing.xl),
          const DsCard(
            child: Column(
              children: [
                DsInfoRow(
                  icon: AppIcons.shield,
                  title: 'Secure and simple',
                  subtitle: 'Links expire and work only once',
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ds.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: ds.border),
            ),
            child: Row(
              children: [
                DsIcon(AppIcons.shield, size: 18, color: ds.accentText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Open the link on this device · Never forward your sign-in email',
                    style: textTheme.bodySmall?.copyWith(
                      color: ds.textMuted,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: DsButton(
                  label: 'Use password instead',
                  variant: DsButtonVariant.secondary,
                  compact: true,
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.login),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DsButton(
                  label: 'Forgot password?',
                  variant: DsButtonVariant.quiet,
                  compact: true,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
