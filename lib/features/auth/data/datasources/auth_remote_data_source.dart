import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_remote_data_source.dart';

const _emailLinkPrefKey = 'devsync_email_link_sign_in';

/// Continue URL hosted on the Firebase project (must be an authorized domain).
const kEmailLinkContinueUrl =
    'https://devsync-36ef3.firebaseapp.com/finishSignIn';

const kAndroidPackageName = 'com.example.devsync_open_source_collaboration_app';

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
      'This account uses Google. Continue with Google instead.';
}

/// Firebase Authentication + Firestore user bootstrap.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    FirebaseAuth? auth,
    UserRemoteDataSource? userRemoteDataSource,
    GoogleSignIn? googleSignIn,
  }) : _authOverride = auth,
       _usersOverride = userRemoteDataSource,
       _googleSignInOverride = googleSignIn;

  final FirebaseAuth? _authOverride;
  final UserRemoteDataSource? _usersOverride;
  final GoogleSignIn? _googleSignInOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  UserRemoteDataSource get _users => _usersOverride ?? UserRemoteDataSource();
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
      if (!fresh.emailVerified) {
        await fresh.sendEmailVerification();
      }
    }
    return credential;
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user to verify',
      );
    }
    await user.sendEmailVerification();
  }

  /// Reloads the user from Firebase and returns whether email is verified.
  Future<bool> reloadAndIsEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  ActionCodeSettings get _emailLinkSettings => ActionCodeSettings(
    url: kEmailLinkContinueUrl,
    handleCodeInApp: true,
    androidPackageName: kAndroidPackageName,
    androidMinimumVersion: '21',
  );

  /// Sends Firebase's hosted password-reset email.
  ///
  /// Looks up sign-in methods first via Identity Toolkit. Google-only accounts
  /// get [GoogleOnlyAccountException] (needs Email enumeration protection off
  /// in Firebase Console). Empty methods fall through to send (user missing
  /// or protection still on).
  ///
  /// [user-not-found] is ignored so the UI never reveals whether the address
  /// has an account.
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    final methods = await _fetchSignInMethods(trimmed);
    final hasPassword = methods.contains('password');
    final hasGoogle = methods.contains('google.com');
    if (hasGoogle && !hasPassword) {
      throw const GoogleOnlyAccountException();
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') return;
      rethrow;
    }
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

  /// Sends a passwordless email-link sign-in message and remembers [email].
  Future<void> sendSignInLinkToEmail(String email) async {
    await _auth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: _emailLinkSettings,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailLinkPrefKey, email.trim());
  }

  Future<String?> pendingEmailLinkAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailLinkPrefKey);
  }

  Future<void> clearPendingEmailLinkAddress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailLinkPrefKey);
  }

  bool isSignInWithEmailLink(String link) => _auth.isSignInWithEmailLink(link);

  /// Completes passwordless sign-in when the app opens an email link.
  ///
  /// Returns `null` if [link] is not an email sign-in link.
  Future<UserCredential?> completeSignInWithEmailLink(String link) async {
    if (!_auth.isSignInWithEmailLink(link)) return null;

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_emailLinkPrefKey);
    if (email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message:
            'Open the link on the same device you requested it from, then try again.',
      );
    }

    final credential = await _auth.signInWithEmailLink(
      email: email,
      emailLink: link,
    );
    await prefs.remove(_emailLinkPrefKey);
    return _afterSignIn(credential);
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
      return _afterSignIn(await _auth.signInWithCredential(credential));
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      // Fallback: browser / Custom Tabs OAuth via Firebase Auth.
      return _afterSignIn(await _auth.signInWithProvider(GoogleAuthProvider()));
    }
  }

  /// GitHub OAuth via Firebase Auth (Custom Tabs / browser).
  Future<UserCredential> signInWithGitHub() async {
    final provider = GithubAuthProvider();
    provider.addScope('read:user');
    provider.addScope('user:email');
    try {
      return _afterSignIn(await _auth.signInWithProvider(provider));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'web-context-canceled' || e.code == 'canceled') {
        throw const AuthCancelledException();
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
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

  /// Removes `users/{uid}` and the Firebase Auth user, then clears the session.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No signed-in user to delete',
      );
    }
    try {
      await _users.deleteUserDoc(user.uid);
    } catch (_) {
      // Still delete Auth so the session cannot stay open.
    }
    try {
      await user.delete();
    } finally {
      await signOut();
    }
  }
}
