import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:devsync_open_source_collaboration_app/features/notifications/data/datasources/notify_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser extends Fake implements User {
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async => 'id-token';
}

class _FakeAuth extends Fake implements FirebaseAuth {
  _FakeAuth({this.user});

  User? user;

  @override
  User? get currentUser => user;
}

class _RecordingClient implements HttpClient {
  Uri? lastUri;
  String? lastBody;
  int statusCode = 200;
  String responseBody = '{"ok":true,"sent":1}';

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    lastUri = url;
    return _RecordingRequest(
      onClose: (body) async {
        lastBody = body;
        return _OkResponse(statusCode, responseBody);
      },
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingRequest implements HttpClientRequest {
  _RecordingRequest({required this.onClose});

  final Future<HttpClientResponse> Function(String body) onClose;
  final _headers = _FakeHeaders();
  final _chunks = <List<int>>[];

  @override
  HttpHeaders get headers => _headers;

  @override
  void write(Object? obj) {
    _chunks.add(utf8.encode('$obj'));
  }

  @override
  Future<HttpClientResponse> close() {
    return onClose(utf8.decode(_chunks.expand((e) => e).toList()));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHeaders implements HttpHeaders {
  @override
  set contentType(ContentType? contentType) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OkResponse extends Stream<List<int>> implements HttpClientResponse {
  _OkResponse(this.statusCode, String body) : _bytes = utf8.encode(body);

  final List<int> _bytes;

  @override
  final int statusCode;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeAuth auth;
  late _RecordingClient client;
  late NotifyRemoteDataSource dataSource;

  setUp(() {
    auth = _FakeAuth(user: _FakeUser());
    client = _RecordingClient();
    dataSource = NotifyRemoteDataSource(
      auth: auth,
      client: client,
      baseUrl: 'https://api.example.com/',
    );
  });

  test('notifyRequestEvent posts requestId + event to /notify', () async {
    await dataSource.notifyRequestEvent(
      requestId: 'req-1',
      event: 'request_received',
    );

    expect(client.lastUri.toString(), 'https://api.example.com/notify');
    final decoded = jsonDecode(client.lastBody!) as Map<String, dynamic>;
    expect(decoded['requestId'], 'req-1');
    expect(decoded['event'], 'request_received');
  });

  test('notifyProjectUpdated posts projectId + project_updated', () async {
    await dataSource.notifyProjectUpdated(projectId: 'proj-9');

    expect(client.lastUri.toString(), 'https://api.example.com/notify');
    final decoded = jsonDecode(client.lastBody!) as Map<String, dynamic>;
    expect(decoded['projectId'], 'proj-9');
    expect(decoded['event'], 'project_updated');
  });

  test('skips HTTP when signed out', () async {
    auth.user = null;
    await dataSource.notifyProjectUpdated(projectId: 'proj-9');
    expect(client.lastUri, isNull);
  });
}
