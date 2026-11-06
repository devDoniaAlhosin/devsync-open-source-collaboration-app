import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/match_request_model.dart';
import '../models/match_response_model.dart';
import 'auth_token_provider.dart';
import 'matching_remote_data_source.dart';

/// Authenticated transport for `POST /matches/generate`.
/// Candidate projects and fallback scoring belong to the backend.
class MatchingHttpRemoteDataSource implements MatchingRemoteDataSource {
  MatchingHttpRemoteDataSource({
    required AuthTokenProvider authTokenProvider,
    String? baseUrl,
    HttpClient? client,
    this.requestTimeout = const Duration(seconds: 45),
  }) : _authTokenProvider = authTokenProvider,
       _baseUrl = baseUrl ?? _defaultMatchingApiBase(),
       _ownsClient = client == null,
       _client = client ?? HttpClient();

  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;
  final HttpClient _client;
  final bool _ownsClient;
  final Duration requestTimeout;

  static String _defaultMatchingApiBase() {
    const override = String.fromEnvironment('DEVSYNC_API_BASE');
    if (override.isNotEmpty) return override;
    const useLocal = bool.fromEnvironment('DEVSYNC_API_LOCAL');
    if (useLocal) {
      return Platform.isAndroid
          ? 'http://10.0.2.2:3000'
          : 'http://127.0.0.1:3000';
    }
    return 'https://devsync-backend-two.vercel.app';
  }

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    try {
      var token = await _getToken();
      var response = await _send(request, token);
      // A forbidden UID is not an expired token. Only retry unauthorized once.
      if (response.statusCode == HttpStatus.unauthorized) {
        token = await _getToken(forceRefresh: true);
        response = await _send(request, token);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw MatchingApiException(
          _messageForStatus(response.statusCode),
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected matching response object');
      }
      return MatchResponseModel.fromJson(decoded);
    } on MatchingApiException {
      rethrow;
    } on AuthTokenException {
      throw const MatchingApiException(
        'Your session could not be verified. Please sign in again.',
        statusCode: 401,
      );
    } on TimeoutException {
      throw const MatchingApiException(
        'Matching took too long. Please try again.',
      );
    } on SocketException {
      throw const MatchingApiException(
        'Cannot reach the matching server. Check your connection and retry.',
      );
    } on HttpException {
      throw const MatchingApiException(
        'Cannot reach the matching server. Please try again.',
      );
    } on FormatException {
      throw const MatchingApiException(
        'The matching server returned an invalid response. Please try again.',
        statusCode: 502,
      );
    } catch (_) {
      throw const MatchingApiException(
        'Matching is unavailable right now. Please try again.',
        statusCode: 500,
      );
    }
  }

  Future<String> _getToken({bool forceRefresh = false}) async {
    final token = await _authTokenProvider
        .getIdToken(forceRefresh: forceRefresh)
        .timeout(requestTimeout);
    if (token == null || token.trim().isEmpty) {
      throw const MatchingApiException(
        'Please sign in to find matches.',
        statusCode: 401,
      );
    }
    return token;
  }

  Future<({int statusCode, String body})> _send(
    MatchRequestModel request,
    String token,
  ) async {
    HttpClientRequest? activeRequest;
    var timedOut = false;
    Future<({int statusCode, String body})> send() async {
      final base = _baseUrl.replaceFirst(RegExp(r'/+$'), '');
      final httpRequest = await _client.postUrl(
        Uri.parse('$base/matches/generate'),
      );
      activeRequest = httpRequest;
      if (timedOut) {
        httpRequest.abort();
        throw TimeoutException('Matching request timed out');
      }
      httpRequest.followRedirects = false;
      httpRequest.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token');
      httpRequest.write(jsonEncode(request.toJson()));
      final response = await httpRequest.close();
      final body = await response.transform(utf8.decoder).join();
      return (statusCode: response.statusCode, body: body);
    }

    return send().timeout(
      requestTimeout,
      onTimeout: () {
        timedOut = true;
        activeRequest?.abort();
        throw TimeoutException('Matching request timed out');
      },
    );
  }

  static String _messageForStatus(int status) => switch (status) {
    400 =>
      'Your matching profile or preferences are invalid. Review them and retry.',
    401 => 'Your session expired. Please sign in again.',
    403 => 'This account is not authorized to request these matches.',
    429 => 'Too many matching requests. Please wait a moment and try again.',
    >= 500 =>
      'The matching service is temporarily unavailable. Please try again.',
    _ => 'The matching request failed. Please try again.',
  };

  @override
  void close() {
    if (_ownsClient) _client.close(force: true);
  }
}

/// Safe, user-facing failure from the matching API.
class MatchingApiException implements Exception {
  const MatchingApiException(this.message, {this.statusCode = 0});

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
