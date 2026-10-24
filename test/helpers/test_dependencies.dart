import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/repositories/auth_repository.dart';

import 'fake_auth_repository.dart';

Future<void> configureTestDependencies({AuthRepository? repository}) async {
  await getIt.reset();
  getIt.registerLazySingleton<AuthRepository>(
    () => repository ?? FakeAuthRepository(),
  );
  registerAuthUseCasesAndCubits();
}
