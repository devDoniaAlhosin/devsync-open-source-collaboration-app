class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.authProviders = const [],
    this.githubLogin,
    this.needsEmailVerification = false,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<String> authProviders;

  /// GitHub username captured at OAuth sign-in (Firestore).
  final String? githubLogin;
  final bool needsEmailVerification;

  bool get hasGithubProvider => authProviders.contains('github.com');
}
