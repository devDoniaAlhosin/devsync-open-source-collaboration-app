import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/data/datasources/auth_email_api.dart';

/// Calls Vercel Admin `POST /notify` after request / project events.
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

  /// Best-effort: logs failures; does not throw to fire-and-forget callers.
  Future<void> notifyRequestEvent({
    required String requestId,
    required String event,
  }) {
    return _postNotify({
      'requestId': requestId,
      'event': event,
    });
  }

  /// Owner updated a project — alert accepted collaborators.
  Future<void> notifyProjectUpdated({required String projectId}) {
    return _postNotify({
      'projectId': projectId,
      'event': 'project_updated',
    });
  }

  Future<void> _postNotify(Map<String, String> body) async {
    final user = _auth.currentUser;
    if (user == null) {
      _log('skip: no signed-in user event=${body['event']}');
      return;
    }

    final token = await user.getIdToken();
    if (token == null || token.isEmpty) {
      _log('skip: empty id token event=${body['event']}');
      return;
    }

    final base = _baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/notify');

    try {
      final request = await _client.postUrl(uri);
      request.headers
        ..contentType = ContentType.json
        ..set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.write(jsonEncode(body));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final code = response.statusCode;

      if (code < 200 || code >= 300) {
        log(
          'POST /notify failed: $code $responseBody body=$body',
          name: 'NotifyRemoteDataSource',
        );
        return;
      }

      if (kDebugMode) {
        _log('ok: $code $responseBody');
      }
    } on Object catch (error, stackTrace) {
      log(
        'POST /notify error body=$body',
        error: error,
        stackTrace: stackTrace,
        name: 'NotifyRemoteDataSource',
      );
    }
  }

  void _log(String message) {
    log(message, name: 'NotifyRemoteDataSource');
  }
}
