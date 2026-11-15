/// Data-layer exceptions. They are mapped to domain `Failure`s by the
/// repository implementation so raw exception text never reaches the UI.
class ProjectNotFoundException implements Exception {
  const ProjectNotFoundException();
}

class ProjectForbiddenException implements Exception {
  const ProjectForbiddenException();
}

class ProjectValidationException implements Exception {
  const ProjectValidationException(this.message);

  final String message;
}

class AuthRequiredException implements Exception {
  const AuthRequiredException();
}

class GithubUnavailableException implements Exception {
  const GithubUnavailableException([this.message = 'GitHub is unavailable']);

  final String message;
}
