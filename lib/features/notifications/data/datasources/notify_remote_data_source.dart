import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/data/datasources/auth_email_api.dart';

/// Calls Vercel Admin `POST /notify` after request create/accept.
class NotifyRemoteDataSource {
  NotifyRemoteDataSource({
    FirebaseAuth? auth,
    HttpClient? client,
    String? baseUrl,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _client = client ?? HttpClient(),
       _baseUrl = baseUrl ?? AuthEmailApi.defaultAuthApiBase();

  final FirebaseAuth _auth;
  final HttpClient _client;
  final String _baseUrl;

  /// Best-effort: never throws to callers that ignore the future.
  Future<void> notifyRequestEvent({
    required String requestId,
    required String event,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) return;

    final base = _baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/notify');
    final request = await _client.postUrl(uri);
    request.headers
      ..contentType = ContentType.json
      ..set(HttpHeaders.authorizationHeader, 'Bearer $token');
    request.write(
      jsonEncode({
        'requestId': requestId,
        'event': event,
      }),
    );
    final response = await request.close();
    // Drain body so the connection can be reused; ignore status (best-effort).
    await response.drain<void>();
  }
}
