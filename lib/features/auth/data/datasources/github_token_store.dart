import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the GitHub OAuth access token + login from device/provider sign-in.
class GithubTokenStore {
  GithubTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'github_oauth_access_token';
  static const _loginKey = 'github_oauth_login';

  final FlutterSecureStorage _storage;

  Future<void> save({required String login, required String accessToken}) async {
    final trimmedLogin = login.trim();
    final trimmedToken = accessToken.trim();
    if (trimmedLogin.isEmpty || trimmedToken.isEmpty) return;
    await Future.wait([
      _storage.write(key: _loginKey, value: trimmedLogin),
      _storage.write(key: _tokenKey, value: trimmedToken),
    ]);
  }

  Future<String?> readLogin() => _storage.read(key: _loginKey);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _loginKey),
      _storage.delete(key: _tokenKey),
    ]);
  }
}
