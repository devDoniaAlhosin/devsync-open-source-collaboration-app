class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.authProviders = const [],
    this.needsEmailVerification = false,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<String> authProviders;
  final bool needsEmailVerification;
}
