import 'package:material_ui/material_ui.dart';

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
  String _code = '';
  bool _loading = false;
  String? _error;

  Map<String, dynamic> get _args {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) return args;
    return const {'email': 'you@devsync.app', 'from': 'code'};
  }

  Future<void> _verify() async {
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

    // Demo OTP from prototype.
    if (_code != '123456') {
      setState(() => _error = 'Invalid code. Demo code is 123456');
      return;
    }

    final from = _args['from'];
    if (from == 'reset') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset verified (demo)')),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final email = (_args['email'] as String?) ?? 'you@devsync.app';

    return AuthScaffold(
      title: 'Verify email',
      onThemeToggle: DevSyncApp.toggleTheme,
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
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: context.ds.danger),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Expires in 10:00',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              AuthTextLink(
                label: 'Resend code',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Demo: code resent (use 123456)'),
                    ),
                  );
                },
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
            message: 'Enter 123456 to verify. No email is sent.',
          ),
        ],
      ),
    );
  }
}
