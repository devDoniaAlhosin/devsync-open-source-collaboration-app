import 'dart:convert';
import 'dart:io';

import '../models/match_item_model.dart';
import '../models/match_request_model.dart';
import '../models/match_response_model.dart';
import '../models/matching_analytics_model.dart';
import 'auth_token_provider.dart';
import 'matching_remote_data_source.dart';

/// HTTP client for the DevSync matching API.
///
/// Calls `POST /matches/generate` on the backend with the developer profile
/// and candidate projects, returning fit scores and reasons from Gemini or
/// the deterministic fallback.
///
/// Requires Firebase authentication - automatically attaches the current
/// user's ID token to all requests.
class MatchingHttpRemoteDataSource implements MatchingRemoteDataSource {
  MatchingHttpRemoteDataSource({
    required AuthTokenProvider authTokenProvider,
    String? baseUrl,
    HttpClient? client,
  }) : _authTokenProvider = authTokenProvider,
       _baseUrl = baseUrl ?? _defaultMatchingApiBase(),
       _client = client ?? HttpClient();

  final AuthTokenProvider _authTokenProvider;
  final String _baseUrl;
  final HttpClient _client;

  /// Production Vercel host. Override with `--dart-define=DEVSYNC_API_BASE=...`.
  static const _hostedBase = 'https://devsync-backend-two.vercel.app';

  static String _defaultMatchingApiBase() {
    const override = String.fromEnvironment('DEVSYNC_API_BASE');
    if (override.isNotEmpty) return override;
    const useLocal = bool.fromEnvironment(
      'DEVSYNC_API_LOCAL',
      defaultValue: false,
    );
    if (useLocal) {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
      return 'http://127.0.0.1:3000';
    }
    return _hostedBase;
  }

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    // Get Firebase ID token for authentication
    final idToken = await _authTokenProvider.getIdToken();
    if (idToken == null) {
      throw const MatchingApiException(
        'Authentication required - please sign in first',
        statusCode: 401,
      );
    }

    final uri = Uri.parse('$_baseUrl/matches/generate');

    try {
      final httpRequest = await _client.postUrl(uri);
      httpRequest.headers
        ..contentType = ContentType.json
        ..set('Authorization', 'Bearer $idToken');
      httpRequest.write(jsonEncode(request.toJson()));

      final response = await httpRequest.close();
      final raw = await response.transform(utf8.decoder).join();

      // Handle auth failures with token refresh
      if (response.statusCode == 401 || response.statusCode == 403) {
        // Try refreshing the token once
        final refreshedToken = await _authTokenProvider.getIdToken(
          forceRefresh: true,
        );
        if (refreshedToken != null) {
          // Retry with fresh token
          return await _retryWithToken(request, refreshedToken);
        }
        throw MatchingApiException(
          'Authentication failed - please sign in again',
          statusCode: response.statusCode,
        );
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (raw.isEmpty) {
          throw const MatchingApiException('Empty response from server');
        }

        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          throw const MatchingApiException('Invalid response format');
        }

        return MatchResponseModel.fromJson(decoded);
      }

      // Try to extract error message from response body
      String errorMessage = 'Matching request failed';
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          errorMessage = decoded['error'] as String? ?? errorMessage;
        }
      } catch (_) {
        // Use default error message if parsing fails
      }

      throw MatchingApiException(errorMessage, statusCode: response.statusCode);
    } on MatchingApiException {
      rethrow;
    } on SocketException {
      throw const MatchingApiException(
        'Cannot reach the DevSync matching server',
        statusCode: 0,
      );
    } on HttpException {
      throw const MatchingApiException(
        'Cannot reach the DevSync matching server',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      throw MatchingApiException(
        'Failed to parse server response: ${e.message}',
      );
    } catch (e) {
      throw MatchingApiException(
        'Unexpected error during matching: ${e.toString()}',
      );
    }
  }

  /// Not implemented for HTTP source - requires different backend endpoint.
  @override
  Future<List<MatchItemModel>> generateMatchesWithPrompt({
    required String prompt,
    Set<String>? tags,
  }) async {
    throw UnimplementedError(
      'generateMatchesWithPrompt is not supported by HTTP data source',
    );
  }

  /// Not implemented for HTTP source - requires different backend endpoint.
  @override
  Future<MatchingAnalyticsModel> getAnalytics() async {
    throw UnimplementedError(
      'getAnalytics is not supported by HTTP data source',
    );
  }

  /// Retry the match request with a refreshed auth token.
  Future<MatchResponseModel> _retryWithToken(
    MatchRequestModel request,
    String token,
  ) async {
    final uri = Uri.parse('$_baseUrl/matches/generate');
    final httpRequest = await _client.postUrl(uri);
    httpRequest.headers
      ..contentType = ContentType.json
      ..set('Authorization', 'Bearer $token');
    httpRequest.write(jsonEncode(request.toJson()));

    final response = await httpRequest.close();
    final raw = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (raw.isEmpty) {
        throw const MatchingApiException('Empty response from server');
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const MatchingApiException('Invalid response format');
      }

      return MatchResponseModel.fromJson(decoded);
    }

    throw MatchingApiException(
      'Matching request failed after token refresh',
      statusCode: response.statusCode,
    );
  }
}

/// Exception thrown when the matching API call fails.
class MatchingApiException implements Exception {
  const MatchingApiException(this.message, {this.statusCode = 0});

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
