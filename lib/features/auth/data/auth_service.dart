import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_repository.dart';

const _emailLinkPrefKey = 'devsync_email_link_sign_in';

/// Continue URL hosted on the Firebase project (must be an authorized domain).
const kEmailLinkContinueUrl =
    'https://devsync-36ef3.firebaseapp.com/finishSignIn';

const kAndroidPackageName =
    'com.example.devsync_open_source_collaboration_app';

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

/// Firebase Authentication + Firestore user bootstrap.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    UserRepository? userRepository,
    GoogleSignIn? googleSignIn,
  })  : _authOverride = auth,
        _usersOverride = userRepository,
        _googleSignInOverride = googleSignIn;

  final FirebaseAuth? _authOverride;
  final UserRepository? _usersOverride;
  final GoogleSignIn? _googleSignInOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  UserRepository get _users => _usersOverride ?? UserRepository();
  GoogleSignIn get _googleSignIn =>
      _googleSignInOverride ?? GoogleSignIn.instance;

  bool _googleReady = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
    final passwordProvider =
        user.providerData.any((p) => p.providerId == 'password');
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

  bool isSignInWithEmailLink(String link) =>
      _auth.isSignInWithEmailLink(link);

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
          message: 'Google Sign-In did not return an ID token. '
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
    await _auth.signOut();
  }

  /// Maps Firebase / Google errors to a short user-facing message.
  static String messageFor(Object error) {
    if (error is AuthCancelledException) {
      return 'Sign-in cancelled';
    }
    if (error is EmailNotVerifiedException) {
      return error.toString();
    }
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Invalid email or password';
        case 'email-already-in-use':
          return 'An account already exists for that email';
        case 'weak-password':
          return 'Password is too weak';
        case 'invalid-email':
          return 'Enter a valid email address';
        case 'network-request-failed':
          return 'Network error. Check your connection';
        case 'account-exists-with-different-credential':
          return 'An account already exists with a different sign-in method';
        case 'operation-not-allowed':
          return 'Enable Email link (passwordless) in Firebase Console';
        case 'invalid-action-code':
          return 'This sign-in link is invalid or expired. Request a new one.';
        case 'missing-email':
          return error.message ??
              'Open the link on the same device you requested it from.';
        default:
          return error.message ?? 'Authentication failed (${error.code})';
      }
    }
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return 'Sign-in cancelled';
      }
      return error.description ?? 'Google Sign-In failed';
    }
    return error.toString();
  }
}
