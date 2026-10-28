import 'package:material_ui/material_ui.dart';

import '../../app/app_routes.dart';
import '../../app/devsync_app.dart';
import '../../core/icons/app_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/ds_button.dart';
import '../../core/widgets/ds_icon.dart';
import '../../core/widgets/ds_page_header.dart';
import '../../core/widgets/ds_text_field.dart';
import 'widgets/auth_divider.dart';
import 'widgets/auth_hero_card.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/auth_social_buttons.dart';
import 'widgets/password_strength_meter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;
  bool _loading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
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
    final email = _email.text.trim();
    final password = _password.text;

    setState(() {
      _emailError = isValidEmail(email) ? null : 'Enter a valid email address';
      _passwordError = password.isEmpty ? 'Password is required' : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Sign in',
      showWordmark: false,
      onThemeToggle: DevSyncApp.toggleTheme,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DsPageHeader(
            eyebrow: 'Welcome back',
            title: 'Your workspace awaits.',
            body: 'Sign in to continue building with your team.',
          ),
          const SizedBox(height: AppSpacing.xl),
          const AuthHeroCard(),
          const SizedBox(height: AppSpacing.xl),
          AuthSocialButtons(
            onGoogle: () => _toast('Google sign-in needs Firebase Auth setup'),
            onGitHub: () => _toast('GitHub sign-in needs backend setup'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AuthDivider(label: 'or continue with email'),
          const SizedBox(height: AppSpacing.lg),
          DsTextField(
            label: 'Work email',
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
            label: 'Password',
            controller: _password,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            errorText: _passwordError,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
              }
            },
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
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        activeColor: AppColors.teal,
                        checkColor: AppColors.onTeal,
                      ),
                      Text(
                        'Remember me',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              AuthTextLink(
                label: 'Forgot password?',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          DsButton(
            label: 'Sign in',
            icon: AppIcons.forward,
            isLoading: _loading,
            onPressed: _loading ? null : _submit,
          ),
          const SizedBox(height: AppSpacing.md),
          DsButton(
            label: 'Sign in with email code',
            variant: DsButtonVariant.secondary,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.codeSignIn),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'New to DevSync?',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              AuthTextLink(
                label: 'Create an account',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.register),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
