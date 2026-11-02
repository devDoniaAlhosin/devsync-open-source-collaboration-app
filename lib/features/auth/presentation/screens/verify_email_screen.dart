import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_otp_field.dart';
import '../../domain/usecases/sign_out.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/verify_code_cubit.dart';
import '../widgets/auth_gate.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_social_buttons.dart';

/// After email/password signup or unverified login: confirm with a 6-digit OTP.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final routeEmail = args is Map<String, dynamic>
        ? args['email'] as String?
        : null;

    return BlocProvider(
      create: (_) {
        final cubit = getIt<VerifyCodeCubit>();
        final target = (email ?? routeEmail)?.trim() ?? '';
        if (target.isNotEmpty) {
          cubit.sendCode(target, purpose: 'verify');
        }
        return cubit;
      },
      child: _VerifyEmailOtpView(email: email ?? routeEmail),
    );
  }
}

class _VerifyEmailOtpView extends StatefulWidget {
  const _VerifyEmailOtpView({this.email});

  final String? email;

  @override
  State<_VerifyEmailOtpView> createState() => _VerifyEmailOtpViewState();
}

class _VerifyEmailOtpViewState extends State<_VerifyEmailOtpView> {
  static const _codeTtl = Duration(minutes: 10);

  String _code = '';
  late DateTime _expiresAt;
  Timer? _ticker;
  Duration _remaining = _codeTtl;

  String get _email {
    final fromWidget = widget.email?.trim();
    if (fromWidget != null && fromWidget.isNotEmpty) return fromWidget;
    final state = getIt<AuthCubit>().state;
    if (state is AuthNeedsVerification) {
      return state.user.email?.trim() ?? '';
    }
    return '';
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

  Future<void> _useAnotherAccount() async {
    await getIt<SignOut>()(const NoParams());
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final email = _email;

    return BlocConsumer<VerifyCodeCubit, VerifyCodeState>(
      listener: (context, state) {
        switch (state) {
          case VerifyCodeSent():
            _startCountdown();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification code sent')),
            );
          case VerifyCodeSuccess():
            getIt<AuthCubit>().refresh();
            navigateToOnboarding(context);
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
          showBack: false,
          onThemeToggle: DevSyncApp.toggleTheme,
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
                    purpose: 'verify',
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
                      cubit.sendCode(email, purpose: 'verify');
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
                        purpose: 'verify',
                      ),
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: AuthTextLink(
                  label: 'Use a different account',
                  onPressed: _useAnotherAccount,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthNote(
                title: 'Email code',
                message:
                    'Codes expire in 10 minutes. Check spam if you do not see the email — tap Resend code if needed.',
              ),
            ],
          ),
        );
      },
    );
  }
}
