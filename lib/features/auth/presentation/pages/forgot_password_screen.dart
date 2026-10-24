import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../../../../core/widgets/ds_card.dart';
import '../../../../core/widgets/ds_google_icon.dart';
import '../../../../core/widgets/ds_text_field.dart';
import '../cubit/forgot_password_cubit.dart';
import '../cubit/login_cubit.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_gate.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_strength_meter.dart';

enum _RecoverStep { form, askMethod, inbox }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _error;
  String? _methodError;
  String? _pendingEmail;
  _RecoverStep _step = _RecoverStep.form;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _askHowTheySignedUp() {
    final email = _email.text.trim();
    setState(() {
      _error = isValidEmail(email) ? null : 'Enter a valid email address';
      if (isValidEmail(email)) {
        _pendingEmail = email;
        _step = _RecoverStep.askMethod;
      }
    });
  }

  void _useDifferentEmail() {
    setState(() {
      _pendingEmail = null;
      _methodError = null;
      _step = _RecoverStep.form;
    });
  }

  void _continueWithPassword(ForgotPasswordCubit cubit) {
    final email = _pendingEmail;
    if (email == null) return;
    setState(() => _methodError = null);
    cubit.sendReset(email);
  }

  void _resend(ForgotPasswordCubit cubit) {
    final email = _pendingEmail;
    if (email == null) return;
    cubit.sendReset(email);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ForgotPasswordCubit>()),
        BlocProvider(create: (_) => getIt<LoginCubit>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              switch (state) {
                case ForgotPasswordSent(:final email):
                  setState(() {
                    _pendingEmail = email;
                    _step = _RecoverStep.inbox;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset link sent')),
                  );
                case ForgotPasswordFailure(:final message):
                  setState(() {
                    if (_step == _RecoverStep.askMethod ||
                        _step == _RecoverStep.inbox) {
                      _methodError = message;
                      _step = _RecoverStep.askMethod;
                    }
                  });
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                default:
                  break;
              }
            },
          ),
          BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              switch (state) {
                case LoginSuccess():
                  navigateToHome(context);
                case LoginNeedsVerification(:final email):
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.verifyEmail,
                    (route) => false,
                    arguments: {'email': email},
                  );
                case LoginFailure(:final message):
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(message)));
                default:
                  break;
              }
            },
          ),
        ],
        child: BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
          builder: (context, resetState) {
            return BlocBuilder<LoginCubit, LoginState>(
              builder: (context, loginState) {
                final resetLoading = resetState is ForgotPasswordLoading;
                final googleLoading = loginState is LoginLoading;
                final busy = resetLoading || googleLoading;
                final resetCubit = context.read<ForgotPasswordCubit>();
                final loginCubit = context.read<LoginCubit>();
                final email = _pendingEmail ?? _email.text.trim();

                return AuthScaffold(
                  title: _step == _RecoverStep.inbox
                      ? 'Check your email'
                      : 'Recover account',
                  onThemeToggle: DevSyncApp.toggleTheme,
                  body: switch (_step) {
                    _RecoverStep.form => _FormBody(
                      email: _email,
                      error: _error,
                      busy: busy,
                      googleLoading: googleLoading,
                      onGoogle: loginCubit.signInWithGoogle,
                      onChanged: () {
                        if (_error != null) setState(() => _error = null);
                      },
                      onContinue: () => _askHowTheySignedUp(),
                      onBackToLogin: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login),
                    ),
                    _RecoverStep.askMethod => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthInlineHeading(
                          orbIcon: AppIcons.mail,
                          eyebrow: 'Account recovery',
                          title: 'Forgot your password?',
                          body:
                              'If you used the Google button, there is no password to reset.',
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        DsTextField(
                          label: 'Email address',
                          controller: _email,
                          enabled: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _HowDidYouSignUpCard(
                          googleLoading: googleLoading,
                          resetLoading: resetLoading,
                          busy: busy,
                          errorText: _methodError,
                          onGoogle: loginCubit.signInWithGoogle,
                          onPassword: () => _continueWithPassword(resetCubit),
                          onDifferentEmail: _useDifferentEmail,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        DsButton(
                          label: 'Back to sign in',
                          variant: DsButtonVariant.quiet,
                          onPressed: busy
                              ? null
                              : () => Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoutes.login),
                        ),
                      ],
                    ),
                    _RecoverStep.inbox => _InboxBody(
                      email: email,
                      loading: resetLoading,
                      googleLoading: googleLoading,
                      busy: busy,
                      onGoogle: loginCubit.signInWithGoogle,
                      onResend: busy ? null : () => _resend(resetCubit),
                      onDifferentEmail: busy ? null : _useDifferentEmail,
                      onBackToLogin: busy
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.login),
                    ),
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.email,
    required this.error,
    required this.busy,
    required this.googleLoading,
    required this.onGoogle,
    required this.onChanged,
    required this.onContinue,
    required this.onBackToLogin,
  });

  final TextEditingController email;
  final String? error;
  final bool busy;
  final bool googleLoading;
  final VoidCallback onGoogle;
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
              "Enter your email and we'll guide you through resetting your password.",
        ),
        const SizedBox(height: AppSpacing.xl),
        const AuthNote(
          title: 'Signed in with Google?',
          message: 'This account has no password. Use Google to get back in.',
        ),
        const SizedBox(height: AppSpacing.md),
        DsButton(
          label: 'Continue with Google',
          leading: const DsGoogleIcon(size: 18),
          variant: DsButtonVariant.quiet,
          isLoading: googleLoading,
          onPressed: busy ? null : onGoogle,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AuthDivider(label: 'or reset with email'),
        const SizedBox(height: AppSpacing.lg),
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
          label: 'Continue',
          icon: AppIcons.forward,
          onPressed: busy ? null : onContinue,
        ),
        const SizedBox(height: AppSpacing.md),
        const AuthNote(
          title: 'Secure recovery.',
          message:
              'We email a reset link from Firebase. Open it to choose a new password, then sign in.',
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

class _InboxBody extends StatelessWidget {
  const _InboxBody({
    required this.email,
    required this.loading,
    required this.googleLoading,
    required this.busy,
    required this.onGoogle,
    required this.onResend,
    required this.onDifferentEmail,
    required this.onBackToLogin,
  });

  final String email;
  final bool loading;
  final bool googleLoading;
  final bool busy;
  final VoidCallback onGoogle;
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
          body:
              'We sent a password reset link to $email. Open it, choose a new password, then sign in.',
        ),
        const SizedBox(height: AppSpacing.xl),
        const AuthNote(
          title: 'Signed in with Google?',
          message:
              'There may be no password to reset. Use Google to get back in.',
        ),
        const SizedBox(height: AppSpacing.md),
        DsButton(
          label: 'Continue with Google',
          leading: const DsGoogleIcon(size: 18),
          variant: DsButtonVariant.quiet,
          isLoading: googleLoading,
          onPressed: busy ? null : onGoogle,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AuthDivider(label: 'or'),
        const SizedBox(height: AppSpacing.lg),
        DsButton(
          label: 'Resend reset link',
          variant: DsButtonVariant.secondary,
          isLoading: loading,
          onPressed: onResend,
        ),
        const SizedBox(height: AppSpacing.md),
        DsButton(
          label: 'Use a different email',
          variant: DsButtonVariant.quiet,
          onPressed: onDifferentEmail,
        ),
        const SizedBox(height: AppSpacing.sm),
        DsButton(
          label: 'Back to sign in',
          variant: DsButtonVariant.quiet,
          onPressed: onBackToLogin,
        ),
        const SizedBox(height: AppSpacing.lg),
        const AuthNote(
          title: 'Tip:',
          message:
              'Check spam if you do not see the email. The link expires after about an hour.',
        ),
      ],
    );
  }
}

class _HowDidYouSignUpCard extends StatelessWidget {
  const _HowDidYouSignUpCard({
    required this.googleLoading,
    required this.resetLoading,
    required this.busy,
    required this.onGoogle,
    required this.onPassword,
    required this.onDifferentEmail,
    this.errorText,
  });

  final bool googleLoading;
  final bool resetLoading;
  final bool busy;
  final VoidCallback onGoogle;
  final VoidCallback onPassword;
  final VoidCallback onDifferentEmail;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ds = context.ds;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return DsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'How did you create this account?',
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'If you used the Google button, there is no password to reset.',
            style: textTheme.bodyMedium?.copyWith(color: ds.textMuted),
          ),
          if (hasError) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              errorText!,
              style: textTheme.bodySmall?.copyWith(color: ds.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          DsButton(
            label: 'Continue with Google',
            leading: const DsGoogleIcon(size: 18),
            variant: DsButtonVariant.quiet,
            isLoading: googleLoading,
            onPressed: busy ? null : onGoogle,
          ),
          const SizedBox(height: AppSpacing.md),
          DsButton(
            label: 'I used email and password',
            icon: AppIcons.forward,
            isLoading: resetLoading,
            onPressed: busy ? null : onPassword,
          ),
          const SizedBox(height: AppSpacing.sm),
          DsButton(
            label: 'Use a different email',
            variant: DsButtonVariant.quiet,
            onPressed: busy ? null : onDifferentEmail,
          ),
        ],
      ),
    );
  }
}
