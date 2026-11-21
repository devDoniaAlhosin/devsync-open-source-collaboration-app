abstract final class AppOAuthConfig {
  /// Override with `--dart-define=GITHUB_OAUTH_CLIENT_ID=...`
  static const String githubClientId = String.fromEnvironment(
    'GITHUB_OAUTH_CLIENT_ID',
    defaultValue: 'Ov23liWSTALY3INKkFZq',
  );
}
