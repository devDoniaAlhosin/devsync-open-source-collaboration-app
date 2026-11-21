import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_oauth_config.dart';
import '../../domain/repositories/auth_repository.dart';
import 'account_cleanup_remote_data_source.dart';
import 'auth_email_api.dart';
import 'github_device_oauth.dart';
import 'github_token_store.dart';
import 'user_remote_data_source.dart';

/// Thrown when the user dismisses a social sign-in flow.
class AuthCancelledException implements Exception {
  const AuthCancelledException();

  @override
  String toString() => 'Sign-in cancelled';
}

/// Email/password account exists but the inbox link was not confirmed yet.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException({this.email});

  final String? email;

  @override
  String toString() => 'Please verify your email before continuing';
}

/// Account only has Google (no password) — reset link will not help.
class GoogleOnlyAccountException implements Exception {
  const GoogleOnlyAccountException();

  @override
  String toString() =>
      'This account uses Google. Sign in with Google instead — '
      'there is no password to reset.';
}

/// Firebase Authentication + Firestore user bootstrap.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? auth,
    UserRemoteDataSource? userRemoteDataSource,
    AccountCleanupRemoteDataSource? accountCleanup,
    AuthEmailApi? emailApi,
    GoogleSignIn? googleSignIn,
    GithubTokenStore? githubTokenStore,
    http.Client? httpClient,
  }) : _authOverride = auth,
       _usersOverride = userRemoteDataSource,
       _cleanupOverride = accountCleanup,
       _emailApi = emailApi ?? AuthEmailApi(),
       _googleSignInOverride = googleSignIn,
       _githubTokens = githubTokenStore ?? GithubTokenStore(),
       _http = httpClient ?? http.Client();

  final FirebaseAuth? _authOverride;
  final UserRemoteDataSource? _usersOverride;
  final AccountCleanupRemoteDataSource? _cleanupOverride;
  final AuthEmailApi _emailApi;
  final GoogleSignIn? _googleSignInOverride;
  final GithubTokenStore _githubTokens;
  final http.Client _http;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  UserRemoteDataSource get _users => _usersOverride ?? UserRemoteDataSource();
  AccountCleanupRemoteDataSource get _cleanup =>
      _cleanupOverride ?? AccountCleanupRemoteDataSource();
  GoogleSignIn get _googleSignIn =>
      _googleSignInOverride ?? GoogleSignIn.instance;

  bool _googleReady = false;

  Stream<User?> get authStateChanges => _auth.userChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleReady) return;
    // Optional Web client ID for Android ID tokens:
    // flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    await _googleSignIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    _googleReady = true;
  }

  Future<UserCredential> _afterSignIn(UserCredential credential) async {
    final user = credential.user;
    if (user != null) {
      await _users.ensureUserDoc(user);
    }
    return credential;
  }

  /// True when the signed-in user used password auth and has not verified email.
  bool get needsEmailVerification {
    final user = _auth.currentUser;
    if (user == null) return false;
    final passwordProvider = user.providerData.any(
      (p) => p.providerId == 'password',
    );
    return passwordProvider && !user.emailVerified;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _afterSignIn(credential);
    final user = _auth.currentUser ?? credential.user;
    if (user != null && !user.emailVerified) {
      throw EmailNotVerifiedException(email: user.email);
    }
    return credential;
  }

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null && displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }
    final fresh = _auth.currentUser ?? user;
    if (fresh != null) {
      await _users.ensureUserDoc(fresh);
    }
    return credential;
  }

  /// Sends a 6-digit reset code via the external email API (not Firebase mail).
  ///
  /// Looks up sign-in methods first via Identity Toolkit. Google-only accounts
  /// get [GoogleOnlyAccountException]. The API never reveals whether the
  /// address has an account.
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    final methods = await _fetchSignInMethods(trimmed);
    final hasPassword = methods.contains('password');
    final hasGoogle = methods.contains('google.com');
    if (hasGoogle && !hasPassword) {
      throw const GoogleOnlyAccountException();
    }
    await _emailApi.sendOtp(email: trimmed, purpose: 'reset');
  }

  Future<void> sendEmailOtp(String email, {String purpose = 'verify'}) {
    return _emailApi.sendOtp(email: email.trim(), purpose: purpose);
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
    String purpose = 'verify',
  }) {
    return _emailApi.verifyOtp(
      email: email.trim(),
      code: code,
      purpose: purpose,
    );
  }

  Future<void> resetPasswordWithOtp({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return _emailApi.resetPassword(
      email: email.trim(),
      code: code,
      newPassword: newPassword,
    );
  }

  Future<void> confirmEmailWithOtp({
    required String email,
    required String code,
  }) async {
    await _emailApi.confirmEmail(email: email.trim(), code: code);
    // Admin marked emailVerified; refresh the client token claim.
    final user = _auth.currentUser;
    if (user != null) await user.reload();
  }

  /// Passwordless sign-in: backend verifies OTP and returns a custom token.
  Future<UserCredential> signInWithEmailOtp({
    required String email,
    required String code,
  }) async {
    final token = await _emailApi.createSession(
      email: email.trim(),
      code: code,
    );
    final credential = await _auth.signInWithCustomToken(token);
    return _afterSignIn(credential);
  }

  /// Uses Identity Toolkit `createAuthUri` (replaces removed
  /// `fetchSignInMethodsForEmail` in firebase_auth 7).
  Future<List<String>> _fetchSignInMethods(String email) async {
    final apiKey = Firebase.app().options.apiKey;
    if (apiKey.isEmpty) return const [];

    final uri = Uri.https(
      'identitytoolkit.googleapis.com',
      '/v1/accounts:createAuthUri',
      {'key': apiKey},
    );
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(
        jsonEncode({'identifier': email, 'continueUri': 'https://localhost/'}),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) return const [];
      final map = jsonDecode(body) as Map<String, dynamic>;
      final methods = map['signinMethods'] as List<dynamic>?;
      return methods?.map((e) => e.toString()).toList() ?? const [];
    } catch (_) {
      return const [];
    } finally {
      client.close(force: true);
    }
  }

  /// Google Sign-In via the native account picker, with provider fallback.
  Future<UserCredential> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw FirebaseAuthException(
          code: 'missing-id-token',
          message:
              'Google Sign-In did not return an ID token. '
              'Enable the Google provider in Firebase Console and set '
              'GOOGLE_SERVER_CLIENT_ID to your Web client ID.',
        );
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await _afterSignIn(await _auth.signInWithCredential(credential));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      // Fallback: browser / Custom Tabs OAuth via Firebase Auth.
      return _afterSignIn(await _auth.signInWithProvider(GoogleAuthProvider()));
    }
  }

  /// GitHub sign-in. Uses device flow on mobile ([AppOAuthConfig.githubClientId]);
  /// otherwise Firebase `signInWithProvider`.
  Future<UserCredential> signInWithGitHub({
    GitHubDeviceCodeHandler? onDeviceCode,
  }) async {
    const clientId = AppOAuthConfig.githubClientId;
    if (clientId.isNotEmpty) {
      return _signInWithGitHubDeviceFlow(
        clientId: clientId,
        onDeviceCode: onDeviceCode,
      );
    }

    final mobile = Platform.isAndroid || Platform.isIOS;
    if (mobile) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message:
            'GitHub sign-in needs a client ID in AppOAuthConfig '
            '(OAuth App with Device Flow enabled).',
      );
    }

    return _signInWithGitHubProvider();
  }

  Future<UserCredential> _signInWithGitHubProvider() async {
    final provider = GithubAuthProvider();
    provider.addScope('read:user');
    provider.addScope('user:email');
    try {
      final credential = await _auth.signInWithProvider(provider);
      final oauth = credential.credential;
      final accessToken = oauth is OAuthCredential ? oauth.accessToken : null;
      return await _afterGitHubSignIn(
        credential,
        accessToken: accessToken,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-canceled' || e.code == 'canceled') {
        throw const AuthCancelledException();
      }
      rethrow;
    }
  }

  Future<UserCredential> _signInWithGitHubDeviceFlow({
    required String clientId,
    GitHubDeviceCodeHandler? onDeviceCode,
  }) async {
    final oauth = GitHubDeviceOAuth(clientId: clientId);
    try {
      final challenge = await oauth.requestCode();
      var cancelled = false;

      // Show the code UI and poll at the same time so the dialog can stay open.
      if (onDeviceCode != null) {
        unawaited(
          onDeviceCode(challenge.userCode, challenge.verificationUri).then((
            proceed,
          ) {
            if (!proceed) cancelled = true;
          }),
        );
      }

      final accessToken = await oauth.pollForAccessToken(
        deviceCode: challenge.deviceCode,
        intervalSeconds: challenge.interval,
        expiresInSeconds: challenge.expiresIn,
        isCancelled: () => cancelled,
      );

      final credential = GithubAuthProvider.credential(accessToken);
      final signedIn = await _auth.signInWithCredential(credential);
      return await _afterGitHubSignIn(signedIn, accessToken: accessToken);
    } on GitHubDeviceOAuthException catch (e) {
      if (e.isCancelled) throw const AuthCancelledException();
      throw FirebaseAuthException(
        code: e.code ?? 'github-device-flow',
        message: e.message,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-canceled' || e.code == 'canceled') {
        throw const AuthCancelledException();
      }
      rethrow;
    } finally {
      oauth.close();
    }
  }

  Future<UserCredential> _afterGitHubSignIn(
    UserCredential credential, {
    String? accessToken,
  }) async {
    final user = credential.user;
    var login = credential.additionalUserInfo?.username?.trim();
    if ((login == null || login.isEmpty) &&
        accessToken != null &&
        accessToken.isNotEmpty) {
      login = await _fetchGithubLogin(accessToken);
    }

    if (user != null) {
      await _users.ensureUserDoc(
        user,
        githubLogin: login,
      );
    }

    if (login != null &&
        login.isNotEmpty &&
        accessToken != null &&
        accessToken.isNotEmpty) {
      await _githubTokens.save(login: login, accessToken: accessToken);
    }

    return credential;
  }

  Future<String?> _fetchGithubLogin(String accessToken) async {
    try {
      final response = await _http.get(
        Uri.https('api.github.com', '/user'),
        headers: {
          'Accept': 'application/vnd.github+json',
          'Authorization': 'Bearer $accessToken',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );
      if (response.statusCode != 200) return null;
      final map = jsonDecode(utf8.decode(response.bodyBytes));
      if (map is! Map<String, dynamic>) return null;
      final login = map['login'] as String?;
      final trimmed = login?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _githubTokens.clear();
    } catch (_) {
      // Best-effort; Auth sign-out still proceeds.
    }
    try {
      if (_googleReady) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Ignore Google sign-out failures when Google was never used.
    }
    try {
      await _auth.signOut();
    } catch (_) {
      // User may already be gone after delete().
    }
  }

  /// Reauth → wipe Firestore → delete Auth. Signs out only after Auth delete.
  Future<void> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No signed-in user to delete',
      );
    }

    await _reauthenticateForDelete(user, password: password);

    final uid = user.uid;
    try {
      await _cleanup.wipeUserData(uid);
    } catch (_) {}

    await user.delete();
    await signOut();
  }

  Future<void> _reauthenticateForDelete(
    User user, {
    String? password,
  }) async {
    final providers = user.providerData.map((p) => p.providerId).toSet();

    if (providers.contains('password')) {
      final email = user.email?.trim() ?? '';
      final pass = password?.trim() ?? '';
      if (email.isEmpty || pass.isEmpty) {
        throw FirebaseAuthException(
          code: 'requires-recent-login',
          message: 'Enter your password to delete this account',
        );
      }
      final credential = EmailAuthProvider.credential(
        email: email,
        password: pass,
      );
      await user.reauthenticateWithCredential(credential);
      return;
    }

    if (providers.contains('google.com')) {
      await _ensureGoogleInitialized();
      try {
        final account = await _googleSignIn.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          throw FirebaseAuthException(
            code: 'requires-recent-login',
            message: 'Sign in with Google again to delete this account',
          );
        }
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        await user.reauthenticateWithCredential(credential);
        return;
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          throw const AuthCancelledException();
        }
        await user.reauthenticateWithProvider(GoogleAuthProvider());
        return;
      }
    }

    if (providers.contains('github.com')) {
      final provider = GithubAuthProvider()
        ..addScope('read:user')
        ..addScope('user:email');
      try {
        await user.reauthenticateWithProvider(provider);
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'web-context-canceled' || e.code == 'canceled') {
          throw const AuthCancelledException();
        }
        rethrow;
      }
    }

    throw FirebaseAuthException(
      code: 'requires-recent-login',
      message: 'Sign in again, then delete your account',
    );
  }
}
