import 'package:material_ui/material_ui.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_notification_tile.dart';
import '../../core/widgets/ds_page_header.dart';
import '../../core/widgets/ds_text_field.dart';
import 'widgets/auth_divider.dart';
import 'widgets/auth_progress_bar.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_social_buttons.dart';
import 'widgets/password_strength_meter.dart';

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
  bool _loading = false;
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

  Future<void> _submit() async {
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

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      stepLabel: '01 / 03',
      onThemeToggle: DevSyncApp.toggleTheme,
      bottom: DsButton(
        label: 'Create account',
        icon: AppIcons.forward,
        isLoading: _loading,
        onPressed: _loading ? null : _submit,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthProgressBar(step: 1),
          const SizedBox(height: AppSpacing.xl),
          const DsPageHeader(
            eyebrow: 'Start building',
            title: 'Create your account.',
            body: 'Meet your next team, find your next project.',
          ),
          const SizedBox(height: AppSpacing.xl),
          AuthSocialButtons(
            onGoogle: () => _toast('Google sign-up needs Firebase Auth setup'),
            onGitHub: () => _toast('GitHub sign-up needs backend setup'),
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
                  onChanged: (v) => setState(() => _acceptedTerms = v ?? false),
                  activeColor: AppColors.teal,
                  checkColor: AppColors.onTeal,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'I agree to the Terms and Privacy Policy',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.ds.textPrimary,
                      ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.ds.textMuted),
              ),
              AuthTextLink(
                label: 'Sign in',
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AppRoutes.login),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
