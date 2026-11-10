import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/matching_dependencies.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/cubit/matching_cubit.dart';

import 'fake_auth_repository.dart';

Future<void> configureTestDependencies({AuthRepository? repository}) async {
  await getIt.reset();
  getIt.registerLazySingleton<AuthRepository>(
    () => repository ?? FakeAuthRepository(),
  );
  registerAuthUseCasesAndCubits();

  // Screens that are given no shared cubit fall back to `getIt<MatchingCubit>()`
  // (and own/close that instance), so this must be a factory.
  getIt.registerFactory<MatchingCubit>(createDemoMatchingCubit);
}
