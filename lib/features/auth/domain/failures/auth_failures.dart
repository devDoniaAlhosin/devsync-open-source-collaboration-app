import '../../../../core/error/failures.dart';

/// Password account exists but the inbox link was not confirmed.
/// Auth-only — other features should not import this.
final class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure({this.email})
    : super('Please verify your email before continuing');

  final String? email;
}
