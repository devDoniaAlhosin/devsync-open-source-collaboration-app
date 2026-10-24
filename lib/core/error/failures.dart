abstract class Failure {
  const Failure(this.message);

  final String message;
}

/// Offline, timeout, or `network-request-failed`.
final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Network error. Check your connection',
  ]);
}

/// Missing document or resource.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

/// Firestore rules, HTTP 403, or a forbidden action.
final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'You do not have permission']);
}

/// Form or payload validation (weak password, invalid field, HTTP 422).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {this.field});

  final String? field;
}

/// Credentials, session, or a signed-out user. Any feature can hit this.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// User dismissed Google, GitHub, or another system sheet.
final class CancelledFailure extends Failure {
  const CancelledFailure([super.message = 'Cancelled']);
}

/// Last-resort fallback. Never pass raw exception text to the UI.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong']);
}
