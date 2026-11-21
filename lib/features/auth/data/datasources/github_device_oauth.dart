import 'dart:convert';

import 'package:http/http.dart' as http;

/// Codes returned by GitHub device login.
class GitHubDeviceChallenge {
  const GitHubDeviceChallenge({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.expiresIn,
    required this.interval,
  });

  final String deviceCode;
  final String userCode;
  final Uri verificationUri;
  final int expiresIn;
  final int interval;
}

class GitHubDeviceOAuthException implements Exception {
  const GitHubDeviceOAuthException(this.message, {this.code});

  final String message;
  final String? code;

  bool get isCancelled => code == 'cancelled' || code == 'access_denied';

  @override
  String toString() => message;
}

/// GitHub device-flow OAuth (request code, poll for token).
/// Needs Device Flow enabled on the OAuth App and [clientId].
class GitHubDeviceOAuth {
  GitHubDeviceOAuth({required this.clientId, http.Client? httpClient})
    : _http = httpClient ?? http.Client(),
      _ownsClient = httpClient == null;

  final String clientId;
  final http.Client _http;
  final bool _ownsClient;

  static final Uri _codeUri = Uri.https('github.com', '/login/device/code');
  static final Uri _tokenUri = Uri.https(
    'github.com',
    '/login/oauth/access_token',
  );

  Future<GitHubDeviceChallenge> requestCode({
    List<String> scopes = const ['read:user', 'user:email'],
  }) async {
    final response = await _http.post(
      _codeUri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'client_id': clientId, 'scope': scopes.join(' ')}),
    );

    final map = _decodeMap(response.body);
    if (response.statusCode == 404) {
      throw const GitHubDeviceOAuthException(
        'GitHub app not found. Check the client ID and Device Flow.',
        code: 'not_found',
      );
    }
    if (response.statusCode != 200 || map['error'] != null) {
      throw GitHubDeviceOAuthException(
        map['error_description'] as String? ??
            map['error'] as String? ??
            'Could not start GitHub sign-in',
        code: map['error'] as String?,
      );
    }

    final complete = map['verification_uri_complete'] as String?;
    final base = map['verification_uri'] as String?;
    return GitHubDeviceChallenge(
      deviceCode: map['device_code'] as String,
      userCode: map['user_code'] as String,
      // Prefer the URL that already includes the user code when GitHub sends it.
      verificationUri: Uri.parse(
        (complete != null && complete.isNotEmpty)
            ? complete
            : (base ?? 'https://github.com/login/device'),
      ),
      expiresIn: (map['expires_in'] as num?)?.toInt() ?? 900,
      interval: (map['interval'] as num?)?.toInt() ?? 5,
    );
  }

  Future<String> pollForAccessToken({
    required String deviceCode,
    required int intervalSeconds,
    required int expiresInSeconds,
    bool Function()? isCancelled,
  }) async {
    var interval = intervalSeconds < 1 ? 5 : intervalSeconds;
    final deadline = DateTime.now().add(Duration(seconds: expiresInSeconds));

    while (DateTime.now().isBefore(deadline)) {
      if (isCancelled?.call() ?? false) {
        throw const GitHubDeviceOAuthException(
          'Sign-in cancelled',
          code: 'cancelled',
        );
      }

      await Future<void>.delayed(Duration(seconds: interval));

      if (isCancelled?.call() ?? false) {
        throw const GitHubDeviceOAuthException(
          'Sign-in cancelled',
          code: 'cancelled',
        );
      }

      final response = await _http.post(
        _tokenUri,
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': clientId,
          'device_code': deviceCode,
          'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
        }),
      );

      final map = _decodeMap(response.body);
      final error = map['error'] as String?;
      if (error == null) {
        final token = map['access_token'] as String?;
        if (token == null || token.isEmpty) {
          throw const GitHubDeviceOAuthException(
            'GitHub did not return an access token',
          );
        }
        return token;
      }

      switch (error) {
        case 'authorization_pending':
          continue;
        case 'slow_down':
          interval += 5;
          continue;
        case 'expired_token':
          throw const GitHubDeviceOAuthException(
            'GitHub sign-in timed out. Try again.',
            code: 'expired_token',
          );
        case 'access_denied':
          throw const GitHubDeviceOAuthException(
            'Sign-in cancelled',
            code: 'cancelled',
          );
        default:
          throw GitHubDeviceOAuthException(
            map['error_description'] as String? ?? error,
            code: error,
          );
      }
    }

    throw const GitHubDeviceOAuthException(
      'GitHub sign-in timed out. Try again.',
      code: 'expired_token',
    );
  }

  void close() {
    if (_ownsClient) _http.close();
  }

  Map<String, dynamic> _decodeMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return const <String, dynamic>{};
  }
}
