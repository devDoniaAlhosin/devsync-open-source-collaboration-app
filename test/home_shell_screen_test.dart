import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/core/widgets/ds_bottom_nav.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/shell/presentation/screens/home_shell_screen.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_dependencies.dart';

void main() {
  setUp(() async {
    await configureTestDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('home shell renders the five-destination dock', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: getIt<AuthCubit>(),
          child: const HomeShellScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final nav = tester.widget<DsBottomNav>(find.byType(DsBottomNav));
    expect(nav.items, hasLength(5));
    expect(nav.items.map((item) => item.label).toList(), [
      'Matches',
      'Discover',
      'Projects',
      'Requests',
      'Profile',
    ]);
    expect(tester.takeException(), isNull);
  });
}
