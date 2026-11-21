import '../../../../core/error/failures.dart';

/// Email/password user has not verified email yet. Auth feature only.
final class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure({this.email})
    : super('Please verify your email before continuing');

  final String? email;
}

/// Google-only account; no password to reset. Auth feature only.
final class GoogleOnlyAccountFailure extends Failure {
  const GoogleOnlyAccountFailure()
    : super(
        'This account uses Google. Sign in with Google instead — '
        'there is no password to reset.',
      );
}
