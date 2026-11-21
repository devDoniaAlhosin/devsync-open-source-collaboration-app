import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_icon.dart';
import '../../../../core/widgets/ds_otp_field.dart';
import '../../../../core/widgets/ds_text_field.dart';
import '../../../../core/widgets/ds_toast.dart';
import '../cubit/forgot_password_cubit.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_meter.dart';

enum _RecoverStep { form, googleOnly, inbox, newPassword, success }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  String? _methodError;
  String? _passwordError;
  String? _pendingEmail;
  String _otp = '';
  String? _verifiedCode;
  _RecoverStep _step = _RecoverStep.form;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _sendCode(ForgotPasswordCubit cubit) {
    final email = _email.text.trim();
    if (!isValidEmail(email)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }
    setState(() {
      _error = null;
      _pendingEmail = email;
    });
    cubit.sendReset(email);
  }

  void _useDifferentEmail() {
    setState(() {
      _pendingEmail = null;
      _methodError = null;
      _otp = '';
      _step = _RecoverStep.form;
    });
  }

  void _resend(ForgotPasswordCubit cubit) {
    final email = _pendingEmail;
    if (email == null) return;
    cubit.sendReset(email);
  }

  void _backToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          switch (state) {
            case ForgotPasswordSent(:final email):
              setState(() {
                _pendingEmail = email;
                _otp = '';
                _step = _RecoverStep.inbox;
              });
              showDsToast(
                context,
                'Reset code sent',
                tone: DsToastTone.success,
              );
            case ForgotPasswordGoogleOnly(:final email):
              setState(() {
                _pendingEmail = email;
                _step = _RecoverStep.googleOnly;
              });
            case ForgotPasswordCodeVerified(:final email, :final code):
              setState(() {
                _pendingEmail = email;
                _verifiedCode = code;
                _step = _RecoverStep.newPassword;
              });
            case ForgotPasswordResetDone():
              setState(() => _step = _RecoverStep.success);
            case ForgotPasswordFailure(:final message):
              setState(() {
                if (_step == _RecoverStep.form) {
                  _error = message;
                } else if (_step == _RecoverStep.inbox) {
                  _methodError = message;
                } else if (_step == _RecoverStep.newPassword) {
                  _passwordError = message;
                }
              });
              showDsToast(context, message, tone: DsToastTone.error);
            default:
              break;
          }
        },
        builder: (context, resetState) {
          final resetLoading = resetState is ForgotPasswordLoading;
          final resetCubit = context.read<ForgotPasswordCubit>();
          final email = _pendingEmail ?? _email.text.trim();

          return AuthScaffold(
            title: switch (_step) {
              _RecoverStep.inbox => 'Enter reset code',
              _RecoverStep.newPassword => 'New password',
              _RecoverStep.success => 'Password updated',
              _RecoverStep.googleOnly => 'Use Google to sign in',
              _ => 'Recover account',
            },
            onThemeToggle: DevSyncApp.toggleTheme,
            body: switch (_step) {
              _RecoverStep.form => _FormBody(
                email: _email,
                error: _error,
                busy: resetLoading,
                resetLoading: resetLoading,
                onChanged: () {
                  if (_error != null) setState(() => _error = null);
                },
                onContinue: () => _sendCode(resetCubit),
                onBackToLogin: _backToLogin,
              ),
              _RecoverStep.googleOnly => _GoogleOnlyBody(
                email: email,
                onDifferentEmail: _useDifferentEmail,
                onBackToLogin: _backToLogin,
              ),
              _RecoverStep.inbox => _InboxBody(
                email: email,
                loading: resetLoading,
                errorText: _methodError,
                onOtpChanged: (value) => setState(() {
                  _otp = value;
                  _methodError = null;
                }),
                onVerify: resetLoading
                    ? null
                    : () => resetCubit.verifyCode(email: email, code: _otp),
                onResend: resetLoading ? null : () => _resend(resetCubit),
                onDifferentEmail: resetLoading ? null : _useDifferentEmail,
                onBackToLogin: resetLoading ? null : _backToLogin,
              ),
              _RecoverStep.newPassword => _NewPasswordBody(
                password: _password,
                confirm: _confirm,
                loading: resetLoading,
                busy: resetLoading,
                errorText: _passwordError,
                onChanged: () => setState(() => _passwordError = null),
                onSubmit: resetLoading || _verifiedCode == null
                    ? null
                    : () {
                        final pass = _password.text;
                        final confirm = _confirm.text;
                        if (pass.length < 8) {
                          setState(
                            () =>
                                _passwordError = 'Use at least 8 characters',
                          );
                          return;
                        }
                        if (pass != confirm) {
                          setState(
                            () => _passwordError = 'Passwords do not match',
                          );
                          return;
                        }
                        resetCubit.resetPassword(
                          email: email,
                          code: _verifiedCode!,
                          newPassword: pass,
                        );
                      },
                onBackToLogin: resetLoading ? null : _backToLogin,
              ),
              _RecoverStep.success => _SuccessBody(onBackToLogin: _backToLogin),
            },
          );
        },
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.email,
    required this.error,
    required this.busy,
    required this.resetLoading,
    required this.onChanged,
    required this.onContinue,
    required this.onBackToLogin,
  });

  final TextEditingController email;
  final String? error;
  final bool busy;
  final bool resetLoading;
  final VoidCallback onChanged;
  final VoidCallback onContinue;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthInlineHeading(
          orbIcon: AppIcons.mail,
          eyebrow: 'Account recovery',
          title: 'Forgot your password?',
          body:
              "Enter your email and we'll send a 6-digit code to reset your password.",
        ),
        const SizedBox(height: AppSpacing.xl),
        DsTextField(
          label: 'Email address',
          controller: email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          errorText: error,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: AppSpacing.lg),
        DsButton(
          label: 'Send code',
          icon: AppIcons.forward,
          isLoading: resetLoading,
          onPressed: busy ? null : onContinue,
        ),
        const SizedBox(height: AppSpacing.md),
        const AuthNote(
          title: 'Secure recovery.',
          message:
              'We email a 6-digit code. Enter it next, then choose a new password.',
        ),
        const SizedBox(height: AppSpacing.lg),
        DsButton(
          label: 'Back to sign in',
          variant: DsButtonVariant.quiet,
          onPressed: busy ? null : onBackToLogin,
        ),
      ],
    );
  }
}

class _GoogleOnlyBody extends StatelessWidget {
  const _GoogleOnlyBody({
    required this.email,
    required this.onDifferentEmail,
    required this.onBackToLogin,
  });

  final String email;
  final VoidCallback onDifferentEmail;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthInlineHeading(
          orbIcon: AppIcons.shield,
          eyebrow: 'No password on this account',
          title: 'This email signs in with Google.',
          body:
              '$email has no password to reset. Go back to sign in and continue with Google.',
        ),
        const SizedBox(height: AppSpacing.xl),
        const AuthNote(
          title: 'Why am I seeing this?',
          message:
              'You created this account with Google. Password reset only works for email/password accounts.',
        ),
        const SizedBox(height: AppSpacing.lg),
        DsButton(
          label: 'Back to sign in',
          icon: AppIcons.forward,
          onPressed: onBackToLogin,
        ),
        const SizedBox(height: AppSpacing.sm),
        DsButton(
          label: 'Use a different email',
          variant: DsButtonVariant.quiet,
          onPressed: onDifferentEmail,
        ),
      ],
    );
  }
}

class _InboxBody extends StatelessWidget {
  const _InboxBody({
    required this.email,
    required this.loading,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
    required this.onDifferentEmail,
    required this.onBackToLogin,
    this.errorText,
  });

  final String email;
  final bool loading;
  final String? errorText;
  final ValueChanged<String> onOtpChanged;
  final VoidCallback? onVerify;
  final VoidCallback? onResend;
  final VoidCallback? onDifferentEmail;
  final VoidCallback? onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          onChanged: onOtpChanged,
          onCompleted: (value) {
            onOtpChanged(value);
            onVerify?.call();
          },
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: context.ds.danger),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        DsButton(
          label: 'Verify code',
          icon: AppIcons.forward,
          isLoading: loading,
          onPressed: onVerify,
        ),
        const SizedBox(height: AppSpacing.md),
        DsButton(
          label: 'Resend code',
          variant: DsButtonVariant.secondary,
          onPressed: onResend,
        ),
        const SizedBox(height: AppSpacing.sm),
        DsButton(
          label: 'Use a different email',
          variant: DsButtonVariant.quiet,
          onPressed: onDifferentEmail,
        ),
        DsButton(
          label: 'Back to sign in',
          variant: DsButtonVariant.quiet,
          onPressed: onBackToLogin,
        ),
      ],
    );
  }
}

class _NewPasswordBody extends StatefulWidget {
  const _NewPasswordBody({
    required this.password,
    required this.confirm,
    required this.loading,
    required this.busy,
    required this.onChanged,
    required this.onSubmit,
    required this.onBackToLogin,
    this.errorText,
  });

  final TextEditingController password;
  final TextEditingController confirm;
  final bool loading;
  final bool busy;
  final String? errorText;
  final VoidCallback onChanged;
  final VoidCallback? onSubmit;
  final VoidCallback? onBackToLogin;

  @override
  State<_NewPasswordBody> createState() => _NewPasswordBodyState();
}

class _NewPasswordBodyState extends State<_NewPasswordBody> {
  bool _obscure = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthInlineHeading(
          orbIcon: AppIcons.lock,
          eyebrow: 'Account recovery',
          title: 'Set a new password.',
          body: 'Choose a strong password to protect your DevSync workspace.',
        ),
        const SizedBox(height: AppSpacing.xl),
        DsTextField(
          label: 'New password',
          controller: widget.password,
          obscureText: _obscure,
          autofillHints: const [AutofillHints.newPassword],
          onChanged: (_) => widget.onChanged(),
          suffix: IconButton(
            tooltip: _obscure ? 'Show password' : 'Hide password',
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: DsIcon(
              _obscure ? AppIcons.eye : AppIcons.eyeOff,
              color: context.ds.textMuted,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PasswordStrengthMeter(password: widget.password.text),
        const SizedBox(height: AppSpacing.md),
        DsTextField(
          label: 'Confirm password',
          controller: widget.confirm,
          obscureText: _obscureConfirm,
          autofillHints: const [AutofillHints.newPassword],
          errorText: widget.errorText,
          onChanged: (_) => widget.onChanged(),
          suffix: IconButton(
            tooltip: _obscureConfirm ? 'Show password' : 'Hide password',
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            icon: DsIcon(
              _obscureConfirm ? AppIcons.eye : AppIcons.eyeOff,
              color: context.ds.textMuted,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        DsButton(
          label: 'Update password',
          icon: AppIcons.forward,
          isLoading: widget.loading,
          onPressed: widget.busy || widget.password.text.length < 8
              ? null
              : widget.onSubmit,
        ),
        const SizedBox(height: AppSpacing.md),
        DsButton(
          label: 'Back to sign in',
          variant: DsButtonVariant.quiet,
          onPressed: widget.onBackToLogin,
        ),
      ],
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.onBackToLogin});

  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    final ds = context.ds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const DsIcon(AppIcons.success, color: AppColors.teal, size: 36),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Password updated.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "You're all set. Sign in with your new password to get back to building.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ds.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        DsButton(
          label: 'Back to sign in',
          icon: AppIcons.forward,
          onPressed: onBackToLogin,
        ),
      ],
    );
  }
}
