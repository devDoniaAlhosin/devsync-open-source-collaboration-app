import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin client for the DevSync Vercel API.
///
/// The API (which owns Gemini Flash-Lite credentials and an FCM service
/// account) is the only place that talks to the LLM and sends push
/// notifications. This client intentionally stays small: project writes commit
/// to Firestore first, then call the API as a best-effort side effect.
///
/// Configure at build time:
///
/// ```sh
/// flutter run \
///   --dart-define=DEVSYNC_API_BASE_URL=https://devsync.vercel.app \
///   --dart-define=DEVSYNC_API_KEY=optional-key
/// ```
class DevSyncApiDataSource {
  DevSyncApiDataSource({
    http.Client? client,
    String? baseUrl,
    String? apiKey,
    Duration timeout = const Duration(seconds: 6),
  }) : _client = client ?? http.Client(),
       _baseUrl = _normalizeBaseUrl(
         baseUrl ?? const String.fromEnvironment('DEVSYNC_API_BASE_URL'),
       ),
       _apiKey = apiKey ?? const String.fromEnvironment('DEVSYNC_API_KEY'),
       _timeout = timeout;

  final http.Client _client;
  final String _baseUrl;
  final String _apiKey;
  final Duration _timeout;

  bool get isConfigured => _baseUrl.isNotEmpty;

  /// Asks the API to push a Cloud Messaging notification to the maintainer.
  ///
  /// Firestore is the source of truth; this is fire-and-forget. Failures are
  /// surfaced to the caller so the repository can log them without failing the
  /// collaboration request itself.
  Future<void> notifyCollaborationRequest({
    required String requestId,
    required String projectId,
    required String projectTitle,
    required String ownerId,
    required String requesterId,
    required String requesterName,
    String? message,
  }) async {
    if (!isConfigured) return;

    final response = await _client
        .post(
          Uri.parse('$_baseUrl/api/collaboration-requests/notify'),
          headers: {
            'Content-Type': 'application/json',
            if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'requestId': requestId,
            'projectId': projectId,
            'projectTitle': projectTitle,
            'ownerId': ownerId,
            'requesterId': requesterId,
            'requesterName': requesterName,
            'message': message ?? '',
          }),
        )
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'DevSync API notification failed (${response.statusCode})',
      );
    }
  }

  static String _normalizeBaseUrl(String value) {
    var normalized = value.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
