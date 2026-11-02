import 'dart:convert';
import 'dart:io';

/// HTTP client for the sibling `devsync_backend` OTP / password API.
class AuthEmailApi {
  AuthEmailApi({String? baseUrl, HttpClient? client})
    : _baseUrl = baseUrl ?? defaultAuthApiBase(),
      _client = client ?? HttpClient();

  final String _baseUrl;
  final HttpClient _client;

  /// Production Vercel host. Override with `--dart-define=DEVSYNC_API_BASE=...`.
  static const _hostedBase = 'https://devsync-backend-two.vercel.app';

  static String defaultAuthApiBase() {
    const override = String.fromEnvironment('DEVSYNC_API_BASE');
    if (override.isNotEmpty) return override;
    const useLocal = bool.fromEnvironment('DEVSYNC_API_LOCAL', defaultValue: false);
    if (useLocal) {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
      return 'http://127.0.0.1:3000';
    }
    return _hostedBase;
  }

  Future<void> sendOtp({
    required String email,
    String purpose = 'verify',
  }) async {
    await _post('/otp/send', {
      'email': email,
      'purpose': purpose,
    });
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
    String purpose = 'verify',
  }) async {
    await _post('/otp/verify', {
      'email': email,
      'code': code,
      'purpose': purpose,
    });
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _post('/password/reset', {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<void> confirmEmail({
    required String email,
    required String code,
  }) async {
    await _post('/email/verify', {
      'email': email,
      'code': code,
    });
  }

  /// Verifies a sign-in OTP and returns a Firebase custom token.
  Future<String> createSession({
    required String email,
    required String code,
  }) async {
    final json = await _post('/auth/session', {
      'email': email,
      'code': code,
    });
    final token = json['customToken'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthEmailApiException('Missing session token');
    }
    return token;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    try {
      final request = await _client.postUrl(uri);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
      final response = await request.close();
      final raw = await response.transform(utf8.decoder).join();
      Map<String, dynamic> json = const {};
      if (raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) json = decoded;
      }
      if (response.statusCode >= 200 && response.statusCode < 300) return json;
      throw AuthEmailApiException(
        json['error'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
      );
    } on AuthEmailApiException {
      rethrow;
    } on SocketException {
      throw const AuthEmailApiException(
        'Cannot reach the DevSync email server',
        statusCode: 0,
      );
    } on HttpException {
      throw const AuthEmailApiException(
        'Cannot reach the DevSync email server',
        statusCode: 0,
      );
    }
  }
}

class AuthEmailApiException implements Exception {
  const AuthEmailApiException(this.message, {this.statusCode = 0});

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
