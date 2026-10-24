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
import '../../../../core/widgets/ds_notification_tile.dart';
import '../../../../core/widgets/ds_page_header.dart';
import '../../../../core/widgets/ds_text_field.dart';
import '../cubit/register_cubit.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_gate.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_social_buttons.dart';
import '../widgets/password_strength_meter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _acceptedTerms = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _submit(RegisterCubit cubit) {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;

    setState(() {
      _nameError = name.isEmpty ? 'Enter your full name' : null;
      _emailError = isValidEmail(email) ? null : 'Enter a valid email address';
      _passwordError = isStrongPassword(password)
          ? null
          : 'Use 8+ characters, uppercase, number and symbol';
    });

    if (_nameError != null || _emailError != null || _passwordError != null) {
      return;
    }
    if (!_acceptedTerms) {
      _toast('Please accept the terms');
      return;
    }

    cubit.register(email: email, password: password, displayName: name);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          switch (state) {
            case RegisterSuccess():
              navigateToHome(context);
            case RegisterNeedsVerification(:final email):
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.verifyEmail,
                (route) => false,
                arguments: {'email': email},
              );
            case RegisterFailure(:final message):
              _toast(message);
            default:
              break;
          }
        },
        builder: (context, state) {
          final loading = state is RegisterLoading;
          final cubit = context.read<RegisterCubit>();
          return AuthScaffold(
            title: 'Create account',
            onThemeToggle: DevSyncApp.toggleTheme,
            bottom: DsButton(
              label: 'Create account',
              icon: AppIcons.forward,
              isLoading: loading,
              onPressed: loading ? null : () => _submit(cubit),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DsPageHeader(
                  eyebrow: 'Start building',
                  title: 'Create your account.',
                  body: 'Meet your next team, find your next project.',
                ),
                const SizedBox(height: AppSpacing.xl),
                AuthSocialButtons(
                  onGoogle: loading ? null : cubit.signInWithGoogle,
                  onGitHub: loading ? null : cubit.signInWithGitHub,
                ),
                const SizedBox(height: AppSpacing.lg),
                const AuthDivider(label: 'or sign up with email'),
                const SizedBox(height: AppSpacing.lg),
                DsTextField(
                  label: 'Full name',
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  errorText: _nameError,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DsTextField(
                  label: 'Email address',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: _emailError,
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DsTextField(
                  label: 'Create password',
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: _passwordError,
                  onChanged: (_) => setState(() => _passwordError = null),
                  suffix: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: DsIcon(
                      _obscure ? AppIcons.eye : AppIcons.eyeOff,
                      color: context.ds.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                PasswordStrengthMeter(password: _password.text),
                const SizedBox(height: AppSpacing.lg),
                InkWell(
                  onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) =>
                            setState(() => _acceptedTerms = v ?? false),
                        activeColor: AppColors.teal,
                        checkColor: AppColors.onTeal,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I agree to the Terms and Privacy Policy',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: context.ds.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const DsBanner(
                  message:
                      'Privacy first. We only use public GitHub activity to suggest projects.',
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.ds.textMuted,
                      ),
                    ),
                    AuthTextLink(
                      label: 'Sign in',
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
