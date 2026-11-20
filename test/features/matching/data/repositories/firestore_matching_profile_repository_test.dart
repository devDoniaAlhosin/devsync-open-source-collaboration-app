// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync_open_source_collaboration_app/core/error/failures.dart';
import 'package:devsync_open_source_collaboration_app/core/result/result.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/firestore_matching_profile_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _TestAuth auth;
  late _TestFirestore firestore;
  late FirestoreMatchingProfileRepository repository;

  setUp(() {
    auth = _TestAuth()..user = _TestUser('user-123', 'Test User');
    firestore = _TestFirestore();
    repository = FirestoreMatchingProfileRepository(
      firestore: firestore,
      auth: auth,
    );
  });

  group('FirestoreMatchingProfileRepository - skills from users collection', () {
    test('returns AuthFailure when user is not signed in', () async {
      auth.user = null;
      final result = await repository.getProfile();
      expect(result, isA<FailureResult<UserProfile>>());
      result.fold(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('Expected AuthFailure'),
      );
    });

    test('reads skills from users collection data["skills"]', () async {
      firestore.documentData['users/user-123'] = {
        'skills': ['Flutter', 'Dart', 'Firebase'],
        'bio': 'Mobile developer',
      };

      final result = await repository.getProfile();
      expect(result, isA<Success<UserProfile>>());
      result.fold((failure) => fail('Expected Success: ${failure.message}'), (
        profile,
      ) {
        expect(profile.uid, 'user-123');
        expect(profile.declaredSkills, ['Flutter', 'Dart', 'Firebase']);
        expect(profile.bio, 'Mobile developer');
      });
    });

    test('reads skills from users collection data["declaredSkills"]', () async {
      firestore.documentData['users/user-123'] = {
        'declaredSkills': ['Python', 'Django'],
      };

      final result = await repository.getProfile();
      expect(result, isA<Success<UserProfile>>());
      result.fold((failure) => fail('Expected Success'), (profile) {
        expect(profile.declaredSkills, ['Python', 'Django']);
      });
    });

    test(
      'merges unique skills from both "skills" and "declaredSkills"',
      () async {
        firestore.documentData['users/user-123'] = {
          'skills': ['Flutter', 'Dart'],
          'declaredSkills': ['Dart', 'Firebase', 'Clean Architecture'],
        };

        final result = await repository.getProfile();
        expect(result, isA<Success<UserProfile>>());
        result.fold((failure) => fail('Expected Success'), (profile) {
          expect(
            profile.declaredSkills,
            containsAll(['Flutter', 'Dart', 'Firebase', 'Clean Architecture']),
          );
          expect(profile.declaredSkills.length, 4);
        });
      },
    );

    test(
      'reads skills, bio, repos from nested profile map (ERD schema)',
      () async {
        firestore.documentData['users/user-123'] = {
          'displayName': 'Lord Of war',
          'email': 'lordofwar975@gmail.com',
          'profile': {
            'name': 'Lord Of war',
            'bio': 'I am flutter developer',
            'skills': ['Java', 'dart', 'Flutter', 'Nodejs', 'firebase'],
            'repos': 5,
            'commits': 12,
            'languages': [
              {'name': 'Dart', 'percent': 80, 'colorArgb': 0},
              {'name': 'Java', 'percent': 20, 'colorArgb': 0},
            ],
          },
        };

        final result = await repository.getProfile();
        expect(result, isA<Success<UserProfile>>());
        result.fold((failure) => fail('Expected Success'), (profile) {
          expect(profile.declaredSkills, [
            'Java',
            'dart',
            'Flutter',
            'Nodejs',
            'firebase',
          ]);
          expect(profile.bio, 'I am flutter developer');
          expect(profile.publicRepoCount, 5);
          expect(profile.totalContributions, 12);
          expect(profile.githubLanguages, {'Dart': 80, 'Java': 20});
        });
      },
    );

    test(
      'updateDeclaredSkills writes to both "skills" and "declaredSkills" in users/{uid}',
      () async {
        final result = await repository.updateDeclaredSkills([
          'Flutter',
          'Dart',
          'Firebase',
        ]);

        expect(result, isA<Success<UserProfile>>());
        expect(firestore.writes.length, 1);
        final written = firestore.writes.first;
        expect(written['skills'], ['Flutter', 'Dart', 'Firebase']);
        expect(written['declaredSkills'], ['Flutter', 'Dart', 'Firebase']);
        expect(written.containsKey('matchingProfileUpdatedAt'), isTrue);
      },
    );

    test(
      'updateDeclaredSkills rejects skills longer than 100 characters',
      () async {
        final longSkill = 'A' * 101;
        final result = await repository.updateDeclaredSkills([
          'Flutter',
          longSkill,
        ]);

        expect(result, isA<FailureResult<UserProfile>>());
        result.fold((failure) {
          expect(failure, isA<ValidationFailure>());
          expect((failure as ValidationFailure).field, 'skills');
        }, (_) => fail('Expected ValidationFailure'));
        expect(firestore.writes, isEmpty);
      },
    );

    test(
      'updateDeclaredSkills normalizes and removes duplicate skills',
      () async {
        final result = await repository.updateDeclaredSkills([
          ' Flutter ',
          'flutter',
          'DART',
          'Dart',
        ]);

        expect(result, isA<Success<UserProfile>>());
        final written = firestore.writes.first;
        expect(written['skills'], ['Flutter', 'DART']);
      },
    );
  });
}

class _TestAuth extends Fake implements FirebaseAuth {
  User? user;
  @override
  User? get currentUser => user;
}

class _TestUser extends Fake implements User {
  _TestUser(this.uid, [this.displayName]);
  @override
  final String uid;
  @override
  final String? displayName;
}

class _TestFirestore extends Fake implements FirebaseFirestore {
  final documentData = <String, Map<String, dynamic>>{};
  final writes = <Map<String, dynamic>>[];

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _TestCollection(this, collectionPath);
  }
}

class _TestCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _TestCollection(this.store, this.collectionPath);
  final _TestFirestore store;
  final String collectionPath;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final docPath = '$collectionPath/$path';
    return _TestDocument(store, docPath);
  }
}

class _TestDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _TestDocument(this.store, this.docPath);
  final _TestFirestore store;
  final String docPath;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async {
    final data = store.documentData[docPath] ?? <String, dynamic>{};
    return _TestDocumentSnapshot(docPath, data);
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store.writes.add(data);
    store.documentData[docPath] = {
      ...store.documentData[docPath] ?? {},
      ...data,
    };
  }
}

class _TestDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  _TestDocumentSnapshot(this.id, this._data);
  @override
  final String id;
  final Map<String, dynamic> _data;

  @override
  bool get exists => _data.isNotEmpty;

  @override
  Map<String, dynamic>? data() => _data;
}
