import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_otp_field.dart';
import '../cubit/verify_code_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_social_buttons.dart';

/// Prototype 4b — enter the 6-digit email OTP.
///
/// [arguments]: `email`, `purpose` (`signin` | `verify`), `alreadySent`.
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  static const _codeTtl = Duration(minutes: 10);

  String _code = '';
  late DateTime _expiresAt;
  Timer? _ticker;
  Duration _remaining = _codeTtl;
  bool _started = false;

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {'email': '', 'purpose': 'verify', 'alreadySent': false};
  }

  String get _purpose {
    final value = (_args['purpose'] as String?) ?? (_args['from'] as String?);
    if (value == 'signin' || value == 'code') return 'signin';
    return 'verify';
  }

  String get _backRoute =>
      _purpose == 'signin' ? AppRoutes.codeSignIn : AppRoutes.login;

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

  @override
  Widget build(BuildContext context) {
    final email = (_args['email'] as String?) ?? '';
    final alreadySent = _args['alreadySent'] == true;

    return BlocProvider(
      create: (_) {
        final cubit = getIt<VerifyCodeCubit>();
        if (email.isNotEmpty && !alreadySent) {
          cubit.sendCode(email, purpose: _purpose);
        } else if (alreadySent) {
          // Parent already sent; start timer on first frame.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _started) return;
            _started = true;
            _startCountdown();
          });
        }
        return cubit;
      },
      child: BlocConsumer<VerifyCodeCubit, VerifyCodeState>(
        listener: (context, state) {
          switch (state) {
            case VerifyCodeSent():
              _startCountdown();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification code sent')),
              );
            case VerifyCodeSuccess():
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
            case VerifyCodeFailure(:final message):
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            default:
              break;
          }
        },
        builder: (context, state) {
          final loading = state is VerifyCodeLoading;
          final cubit = context.read<VerifyCodeCubit>();
          final error = state is VerifyCodeFailure ? state.message : null;

          return AuthScaffold(
            title: 'Verify email',
            onThemeToggle: DevSyncApp.toggleTheme,
            onBack: () =>
                Navigator.of(context).pushReplacementNamed(_backRoute),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthInlineHeading(
                  orbIcon: AppIcons.mail,
                  eyebrow: 'One last step',
                  title: 'Check your inbox.',
                  body: email.isEmpty
                      ? 'Enter the 6-digit code we emailed you.'
                      : 'Enter the 6-digit code sent to $email.',
                ),
                const SizedBox(height: AppSpacing.xl),
                DsOtpField(
                  onChanged: (value) => setState(() => _code = value),
                  onCompleted: (value) {
                    _code = value;
                    if (email.isEmpty) return;
                    cubit.confirm(
                      email: email,
                      code: value,
                      purpose: _purpose,
                    );
                  },
                ),
                if (error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    error,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: context.ds.danger),
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
                      onPressed: () {
                        if (loading || email.isEmpty) return;
                        cubit.sendCode(email, purpose: _purpose);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                DsButton(
                  label: 'Verify and continue',
                  icon: AppIcons.forward,
                  isLoading: loading,
                  onPressed: loading || email.isEmpty
                      ? null
                      : () => cubit.confirm(
                          email: email,
                          code: _code,
                          purpose: _purpose,
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                const AuthNote(
                  title: 'Email code',
                  message:
                      'Codes expire in 10 minutes. Check spam if the email is slow.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
