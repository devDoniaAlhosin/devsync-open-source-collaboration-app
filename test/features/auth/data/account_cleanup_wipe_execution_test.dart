import 'package:devsync_open_source_collaboration_app/features/auth/data/datasources/account_cleanup_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wipeUserData runs cascade steps in order via injectables', () async {
    final fieldDeletes = <String>[];
    final subDeletes = <String>[];
    final userDeletes = <String>[];

    final cleanup = AccountCleanupRemoteDataSource(
      deleteByField: (collection, field, uid) async {
        fieldDeletes.add('$collection.$field:$uid');
      },
      deleteSubcollection: (uid, sub) async {
        subDeletes.add('users.$sub:$uid');
      },
      deleteUserDoc: (uid) async {
        userDeletes.add(uid);
      },
    );

    await cleanup.wipeUserData('u1');

    expect(fieldDeletes, [
      'feedbacks.userId:u1',
      'matches.userId:u1',
      'requests.senderId:u1',
      'requests.ownerId:u1',
      'projects.ownerId:u1',
      'views.viewerId:u1',
    ]);
    expect(subDeletes, [
      'users.notifications:u1',
      'users.fcmTokens:u1',
    ]);
    expect(userDeletes, ['u1']);
  });

  test('wipeUserData continues after a failing step', () async {
    final ran = <String>[];
    final cleanup = AccountCleanupRemoteDataSource(
      deleteByField: (collection, field, uid) async {
        ran.add('$collection.$field');
        if (collection == 'matches') {
          throw StateError('simulated');
        }
      },
      deleteSubcollection: (uid, sub) async {
        ran.add('users.$sub');
      },
      deleteUserDoc: (uid) async {
        ran.add('users.doc');
      },
    );

    await cleanup.wipeUserData('u1');

    expect(ran, containsAll(AccountCleanupRemoteDataSource.wipeSteps));
    expect(ran.last, 'users.doc');
  });

  test('wipeUserData no-ops on empty uid', () async {
    var called = false;
    final cleanup = AccountCleanupRemoteDataSource(
      deleteByField: (_, _, _) async {
        called = true;
      },
      deleteSubcollection: (_, _) async {
        called = true;
      },
      deleteUserDoc: (_) async {
        called = true;
      },
    );

    await cleanup.wipeUserData('  ');
    expect(called, isFalse);
  });
}
