class GithubProfileException implements Exception {
  const GithubProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GithubUserNotFoundException extends GithubProfileException {
  const GithubUserNotFoundException([
    super.message = 'GitHub user not found',
  ]);
}

class GithubProfileNetworkException extends GithubProfileException {
  const GithubProfileNetworkException([
    super.message = 'Could not reach GitHub',
  ]);
}
