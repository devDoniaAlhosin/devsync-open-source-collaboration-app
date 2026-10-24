import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_routes.dart';
import '../../../../app/devsync_app.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/icons/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/ds_button.dart';
import '../cubit/verify_email_cubit.dart';
import '../widgets/auth_gate.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_social_buttons.dart';

/// After email/password signup: wait until Firebase email link is confirmed.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VerifyEmailCubit>(),
      child: _VerifyEmailView(email: email),
    );
  }
}

class _VerifyEmailView extends StatelessWidget {
  const _VerifyEmailView({this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
      listener: (context, state) {
        switch (state) {
          case VerifyEmailResent():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification email sent')),
            );
          case VerifyEmailVerified():
            navigateToHome(context);
          case VerifyEmailNotYet():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Not verified yet. Open the link in your email first.',
                ),
              ),
            );
          case VerifyEmailSignedOut():
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
          case VerifyEmailFailure(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          default:
            break;
        }
      },
      builder: (context, state) {
        final cubit = context.read<VerifyEmailCubit>();
        final displayEmail = email ?? cubit.currentEmail ?? 'your email';
        final loading = state is VerifyEmailChecking;
        final resending = state is VerifyEmailResending;

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
                title: 'Confirm your email.',
                body:
                    'We sent a verification link to $displayEmail. Open it, then come back and continue.',
              ),
              const SizedBox(height: AppSpacing.xl),
              DsButton(
                label: 'I verified — continue',
                icon: AppIcons.forward,
                isLoading: loading,
                onPressed: loading ? null : cubit.checkVerified,
              ),
              const SizedBox(height: AppSpacing.md),
              DsButton(
                label: 'Resend verification email',
                variant: DsButtonVariant.secondary,
                isLoading: resending,
                onPressed: resending ? null : cubit.resend,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: AuthTextLink(
                  label: 'Use a different account',
                  onPressed: cubit.useAnotherAccount,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AuthNote(
                title: 'Tip:',
                message:
                    'Check spam if you do not see the email. The link expires after a while — tap Resend if needed.',
              ),
            ],
          ),
        );
      },
    );
  }
}
