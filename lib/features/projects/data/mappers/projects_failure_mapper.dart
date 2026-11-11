import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;

import '../../../../core/error/failures.dart';
import '../exceptions/projects_exceptions.dart';

Failure mapProjectsError(Object error) {
  if (error is ProjectNotFoundException) {
    return const NotFoundFailure('Project not found');
  }
  if (error is ProjectForbiddenException) {
    return const PermissionFailure('You can only edit your own projects');
  }
  if (error is ProjectValidationException) {
    return ValidationFailure(error.message);
  }
  if (error is AuthRequiredException) {
    return const AuthFailure('Sign in to manage projects');
  }
  if (error is GithubUnavailableException) {
    return NetworkFailure(error.message);
  }
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
      case 'unauthenticated':
        return const PermissionFailure();
      case 'not-found':
        return const NotFoundFailure('Project not found');
      case 'unavailable':
      case 'deadline-exceeded':
      case 'cancelled':
        return const NetworkFailure();
      case 'failed-precondition':
        return const UnexpectedFailure('This action needs a Firestore index');
      case 'resource-exhausted':
        return const UnexpectedFailure(
          'Too many requests right now. Try again shortly',
        );
      default:
        return const UnexpectedFailure();
    }
  }
  // `http` wraps socket-level failures in [http.ClientException], and
  // `TimeoutException` covers our own request timeouts. (Avoids `dart:io` so
  // the feature also compiles for web.)
  if (error is TimeoutException || error is http.ClientException) {
    return const NetworkFailure();
  }
  return const UnexpectedFailure();
}
