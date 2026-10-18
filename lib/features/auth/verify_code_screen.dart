import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_otp_field.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_social_buttons.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const _codeTtl = Duration(minutes: 10);

  String _code = '';
  bool _loading = false;
  String? _error;
  late DateTime _expiresAt;
  Timer? _ticker;
  Duration _remaining = _codeTtl;

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {'email': 'you@devsync.app', 'from': 'code'};
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _ticker?.cancel();
    _expiresAt = DateTime.now().add(_codeTtl);
    _remaining = _codeTtl;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final left = _expiresAt.difference(DateTime.now());
      setState(() {
        _remaining = left.isNegative ? Duration.zero : left;
      });
      if (left.isNegative) _ticker?.cancel();
    });
  }

  String get _countdownLabel {
    final m = _remaining.inMinutes.clamp(0, 99);
    final s = _remaining.inSeconds.remainder(60).clamp(0, 59);
    return 'Expires in $m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _verify() async {
    if (_remaining == Duration.zero) {
      setState(() => _error = 'Code expired. Tap Resend code.');
      return;
    }
    if (_code.length != 6) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _loading = false);

    // Demo OTP until email OTP backend / Cloud Function lands.
    if (_code != '123456') {
      setState(() => _error = 'Invalid code. Demo code is 123456');
      return;
    }

    final from = _args['from'];
    if (from == 'reset') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset verified (demo)')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _resend() {
    _startCountdown();
    setState(() {
      _code = '';
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo: code resent (use 123456)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = (_args['email'] as String?) ?? 'you@devsync.app';
    final from = _args['from'];
    final backTo =
        from == 'reset' ? AppRoutes.forgotPassword : AppRoutes.codeSignIn;

    return AuthScaffold(
      title: 'Verify email',
      onThemeToggle: DevSyncApp.toggleTheme,
      onBack: () => Navigator.of(context).pushReplacementNamed(backTo),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthInlineHeading(
            orbIcon: AppIcons.mail,
            eyebrow: 'One last step',
            title: 'Check your inbox.',
            body: 'Enter the 6-digit code sent to $email.',
          ),
          const SizedBox(height: AppSpacing.xl),
          DsOtpField(
            onChanged: (v) => setState(() {
              _code = v;
              _error = null;
            }),
            onCompleted: (v) {
              _code = v;
              _verify();
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: context.ds.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                _countdownLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _remaining == Duration.zero
                          ? context.ds.danger
                          : context.ds.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              AuthTextLink(
                label: 'Resend code',
                onPressed: _resend,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Verify and continue',
            icon: AppIcons.forward,
            isLoading: _loading,
            onPressed: _loading ? null : _verify,
          ),
          const SizedBox(height: AppSpacing.md),
          const AuthNote(
            title: 'Interactive prototype:',
            message: 'Enter 123456 to verify. No email is sent yet.',
          ),
        ],
      ),
    );
  }
}
