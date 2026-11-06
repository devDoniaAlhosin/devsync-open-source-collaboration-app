/// Domain failures for the matching feature.
///
/// These provide user-friendly error messages and indicate whether
/// the error is retryable.
sealed class MatchingFailure {
  const MatchingFailure({
    required this.message,
    required this.userMessage,
    required this.retryable,
  });

  /// Technical error message (for logging/debugging).
  final String message;

  /// User-friendly error message to display in UI.
  final String userMessage;

  /// Whether the user can retry this operation.
  final bool retryable;
}

/// Network connectivity failure.
class NetworkFailure extends MatchingFailure {
  const NetworkFailure()
    : super(
        message: 'Network error occurred',
        userMessage:
            'No internet connection. Please check your network and try again.',
        retryable: true,
      );
}

/// Authentication/authorization failure.
class AuthFailure extends MatchingFailure {
  const AuthFailure()
    : super(
        message: 'Authentication failed',
        userMessage: 'Your session has expired. Please sign in again.',
        retryable: false,
      );
}

/// Rate limit exceeded.
class RateLimitFailure extends MatchingFailure {
  const RateLimitFailure()
    : super(
        message: 'Rate limit exceeded',
        userMessage: 'Too many requests. Please try again in a few minutes.',
        retryable: true,
      );
}

/// Server error (5xx).
class ServerFailure extends MatchingFailure {
  const ServerFailure()
    : super(
        message: 'Server error occurred',
        userMessage: 'Something went wrong on our end. Please try again later.',
        retryable: true,
      );
}

/// No matches found (not really an error, informational).
class NoMatchesFailure extends MatchingFailure {
  const NoMatchesFailure()
    : super(
        message: 'No matches found',
        userMessage:
            'No projects match your skills right now. Try updating your profile or check back later.',
        retryable: false,
      );
}

/// Profile not found or incomplete.
class ProfileIncompleteFailure extends MatchingFailure {
  const ProfileIncompleteFailure()
    : super(
        message: 'Profile incomplete',
        userMessage:
            'Please add skills to your profile to get match recommendations.',
        retryable: false,
      );
}

/// Invalid request data.
class ValidationFailure extends MatchingFailure {
  const ValidationFailure(String details)
    : super(
        message: 'Validation failed: $details',
        userMessage: 'Invalid request. Please check your profile data.',
        retryable: false,
      );
}

/// Generic/unknown failure.
class UnknownFailure extends MatchingFailure {
  const UnknownFailure([String? details])
    : super(
        message: details ?? 'Unknown error occurred',
        userMessage:
            'Something went wrong. Please try again or contact support.',
        retryable: true,
      );
}
