abstract final class AppOAuthConfig {
  /// Override with `--dart-define=GITHUB_OAUTH_CLIENT_ID=...`
  static const String githubClientId = String.fromEnvironment(
    'GITHUB_OAUTH_CLIENT_ID',
    defaultValue: 'Ov23liWSTALY3INKkFZq',
  );

  /// Firebase Web client ID (client_type 3 in google-services.json).
  /// Needed on Android so Google Sign-In returns an ID token for Firebase Auth.
  /// Override with `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '276979676513-vf2shrnicvjvoo9jl8d89c4kqv1d0je0.apps.googleusercontent.com',
  );
}
