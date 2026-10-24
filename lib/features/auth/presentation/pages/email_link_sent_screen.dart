import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../cubit/email_link_cubit.dart';
import '../widgets/auth_scaffold.dart';

/// Waiting screen after a passwordless email link was sent.
class EmailLinkSentScreen extends StatefulWidget {
  const EmailLinkSentScreen({super.key, this.email});

  final String? email;

  @override
  State<EmailLinkSentScreen> createState() => _EmailLinkSentScreenState();
}

class _EmailLinkSentScreenState extends State<EmailLinkSentScreen> {
  String? _email;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<EmailLinkCubit>();
        if (_email == null) {
          cubit.pendingEmailLinkAddress().then((value) {
            if (mounted) setState(() => _email = value);
          });
        }
        return cubit;
      },
      child: BlocConsumer<EmailLinkCubit, EmailLinkState>(
        listener: (context, state) {
          switch (state) {
            case EmailLinkSent():
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sign-in link sent again')),
              );
            case EmailLinkFailure(:final message):
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
            default:
              break;
          }
        },
        builder: (context, state) {
          final email = _email ?? 'your email';
          final resending = state is EmailLinkLoading;

          return AuthScaffold(
            title: 'Check your email',
            onThemeToggle: DevSyncApp.toggleTheme,
            onBack: () => Navigator.of(
              context,
            ).pushReplacementNamed(AppRoutes.codeSignIn),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthInlineHeading(
                  orbIcon: AppIcons.mail,
                  eyebrow: 'One last step',
                  title: 'Open your inbox.',
                  body:
                      'We sent a sign-in link to $email. Tap it on this device to finish signing in.',
                ),
                const SizedBox(height: AppSpacing.xl),
                DsButton(
                  label: 'Resend sign-in link',
                  variant: DsButtonVariant.secondary,
                  isLoading: resending,
                  onPressed: resending || _email == null || _email!.isEmpty
                      ? null
                      : () => context.read<EmailLinkCubit>().sendLink(_email!),
                ),
                const SizedBox(height: AppSpacing.md),
                DsButton(
                  label: 'Use password instead',
                  variant: DsButtonVariant.quiet,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AuthNote(
                  title: 'Tip:',
                  message:
                      'Keep this app open. After you tap the link, DevSync will sign you in automatically. Check spam if you do not see the email.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
