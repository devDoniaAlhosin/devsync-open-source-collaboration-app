import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/liked_matches_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

const _match = MatchItem(
  projectId: 'project-1',
  projectName: 'Project',
  description: 'A project from the API.',
  githubUrl: 'https://github.com/team/project',
  neededSkills: ['Dart'],
  score: 82,
  reason: 'Dart skills overlap.',
  maintainerId: 'owner-1',
  isFallback: true,
);

void main() {
  late _Auth auth;
  late _Firestore firestore;
  late FirestoreLikedMatchesDataSource source;

  setUp(() {
    auth = _Auth()..user = _User('user-a');
    firestore = _Firestore();
    source = FirestoreLikedMatchesDataSource(
      firestore: firestore,
      auth: auth,
      operationTimeout: const Duration(milliseconds: 30),
    );
  });

  test(
    'signed-out reads and mutations fail without accessing Firestore',
    () async {
      auth.user = null;
      for (final operation in <Future<void> Function()>[
        () async => source.getLikedMatches(),
        () => source.addLikedMatch(_match),
        () => source.removeLikedMatch(_match.projectId),
        source.clearLikedMatches,
      ]) {
        await expectLater(operation(), throwsA(isA<LikedMatchesException>()));
      }
      expect(firestore.paths, isEmpty);
    },
  );

  test(
    'writes real match fields into the match collection (ERD schema)',
    () async {
      await source.addLikedMatch(_match, promptVersion: 'ranker-v1');

      expect(firestore.paths, contains('matches/user-a_project-1'));
      final data = firestore.writes.first;
      expect(data['matchId'], 'user-a_project-1');
      expect(data['userId'], 'user-a');
      expect(data['projectId'], _match.projectId);
      expect(data['score'], 82);
      expect(data['reason'], _match.reason);
      expect(data['promptVersion'], 'ranker-v1');
      expect(data['projectName'], _match.projectName);
      expect(data['maintainerId'], 'owner-1');
      expect(data['createdAt'], isA<FieldValue>());
    },
  );

  test('reads saved matches in descending saved-time order', () async {
    firestore.documents = [_Snapshot('user-a_project-1', _storedMatch())];
    final matches = await source.getLikedMatches();

    expect(matches.single.projectId, 'project-1');
    expect(matches.single.projectName, _match.projectName);
    expect(matches.single.maintainerId, 'owner-1');
  });

  test('read failure is distinct from an empty saved list', () async {
    expect(await source.getLikedMatches(), isEmpty);
    firestore.readError = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
      message: 'private diagnostic',
    );
    await expectLater(
      source.getLikedMatches(),
      throwsA(
        isA<LikedMatchesException>().having(
          (error) => error.message,
          'safe message',
          allOf(contains('Could not load'), isNot(contains('private'))),
        ),
      ),
    );
  });

  test('write and remove failures are reported', () async {
    firestore.writeError = FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
    );
    await expectLater(
      source.addLikedMatch(_match),
      throwsA(isA<LikedMatchesException>()),
    );
    await expectLater(
      source.removeLikedMatch('project-1'),
      throwsA(isA<LikedMatchesException>()),
    );
  });

  test('invalid project IDs never perform a mutation', () async {
    for (final id in ['', ' ', 'other/project']) {
      await expectLater(
        source.removeLikedMatch(id),
        throwsA(isA<LikedMatchesException>()),
      );
    }
    expect(firestore.deletedPaths, isEmpty);
  });

  test('malformed or mismatched saved documents report a data error', () async {
    for (final document in [
      _Snapshot('user-a_project-1', {'score': 'not-a-number'}),
    ]) {
      firestore.documents = [document];
      await expectLater(
        source.getLikedMatches(),
        throwsA(
          isA<LikedMatchesException>().having(
            (error) => error.message,
            'message',
            contains('could not be read'),
          ),
        ),
      );
    }
  });

  test('account switch discards an in-flight read result', () async {
    final gate = Completer<void>();
    firestore.readGate = gate.future;
    firestore.documents = [_Snapshot('user-a_project-1', _storedMatch())];
    final request = source.getLikedMatches();
    auth.user = _User('user-b');
    gate.complete();

    await expectLater(request, throwsA(isA<LikedMatchesException>()));
    expect(firestore.paths, contains('matches'));
    expect(firestore.paths.any((path) => path.contains('user-b')), isFalse);
  });

  test(
    'account switch during save does not report success for new user',
    () async {
      final gate = Completer<void>();
      firestore.writeGate = gate.future;
      final request = source.addLikedMatch(_match);
      auth.user = _User('user-b');
      gate.complete();

      await expectLater(request, throwsA(isA<LikedMatchesException>()));
      expect(firestore.paths.any((path) => path.contains('user-b')), isFalse);
    },
  );

  test('timeout is surfaced instead of waiting indefinitely', () async {
    final gate = Completer<void>();
    firestore.readGate = gate.future;
    await expectLater(
      source.getLikedMatches(),
      throwsA(
        isA<LikedMatchesException>().having(
          (error) => error.message,
          'message',
          contains('taking too long'),
        ),
      ),
    );
    gate.complete();
  });

  test('clear uses batches of at most 500 writes', () async {
    firestore.documents = List.generate(
      501,
      (index) => _Snapshot('user-a_project-$index', _storedMatch()),
    );
    await source.clearLikedMatches();

    expect(firestore.batchSizes, [500, 1]);
  });

  test('a timed-out clear does not continue deleting later batches', () async {
    final gate = Completer<void>();
    firestore.batchGate = gate.future;
    firestore.documents = List.generate(
      501,
      (index) => _Snapshot('user-a_project-$index', _storedMatch()),
    );
    await expectLater(
      source.clearLikedMatches(),
      throwsA(isA<LikedMatchesException>()),
    );
    gate.complete();
    await Future<void>.delayed(Duration.zero);
    expect(firestore.batchSizes, [500]);
  });

  test('in-memory test stores start empty and are isolated', () async {
    final first = InMemoryLikedMatchesDataSource();
    final second = InMemoryLikedMatchesDataSource();
    expect(await first.getLikedMatches(), isEmpty);
    await first.addLikedMatch(_match);
    await first.addLikedMatch(_match);
    expect(await first.getLikedMatches(), hasLength(1));
    expect(await second.getLikedMatches(), isEmpty);
    await first.removeLikedMatch('project-1');
    expect(await first.getLikedMatches(), isEmpty);
  });
}

Map<String, dynamic> _storedMatch({String userId = 'user-a'}) => {
  'matchId': '${userId}_${_match.projectId}',
  'userId': userId,
  'projectId': _match.projectId,
  'score': _match.score,
  'reason': _match.reason,
  'promptVersion': 'v1',
  'projectName': _match.projectName,
  'description': _match.description,
  'githubUrl': _match.githubUrl,
  'neededSkills': _match.neededSkills,
  'maintainerId': _match.maintainerId,
  'createdAt': Timestamp.now(),
};

class _Auth extends Fake implements FirebaseAuth {
  User? user;
  @override
  User? get currentUser => user;
}

class _User extends Fake implements User {
  _User(this.uid);
  @override
  final String uid;
}

class _Firestore extends Fake implements FirebaseFirestore {
  final paths = <String>[];
  final writes = <Map<String, dynamic>>[];
  final deletedPaths = <String>[];
  final batchSizes = <int>[];
  List<_Snapshot> documents = [];
  Object? readError;
  Object? writeError;
  Future<void>? readGate;
  Future<void>? writeGate;
  Future<void>? batchGate;
  String? orderField;
  bool? orderDescending;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    paths.add(collectionPath);
    return _Collection(this, collectionPath);
  }

  @override
  WriteBatch batch() => _Batch(this);
}

class _Collection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _Collection(this.store, this.path);
  final _Firestore store;
  @override
  final String path;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final documentPath = '${this.path}/$path';
    store.paths.add(documentPath);
    return _Document(store, documentPath);
  }

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return this;
  }

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    store.orderField = field as String;
    store.orderDescending = descending;
    return this;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    await store.readGate;
    if (store.readError case final error?) throw error;
    return _QuerySnapshot(store.documents);
  }
}

class _Document extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _Document(this.store, this.path);
  final _Firestore store;
  @override
  final String path;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    final fullPath = '$path/$collectionPath';
    store.paths.add(fullPath);
    return _Collection(store, fullPath);
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    await store.writeGate;
    if (store.writeError case final error?) throw error;
    store.writes.add(data);
  }

  @override
  Future<void> delete() async {
    await store.writeGate;
    if (store.writeError case final error?) throw error;
    store.deletedPaths.add(path);
  }
}

class _QuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  _QuerySnapshot(this.docs);
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
}

class _Snapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _Snapshot(this.id, this.value);
  @override
  final String id;
  final Map<String, dynamic> value;
  @override
  Map<String, dynamic> data() => value;
  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      _Document(_Firestore(), id);
}

class _Batch extends Fake implements WriteBatch {
  _Batch(this.store);
  final _Firestore store;
  int size = 0;
  @override
  void delete(DocumentReference<Object?> document) => size++;
  @override
  Future<void> commit() async {
    store.batchSizes.add(size);
    await store.batchGate;
  }
}
