import 'package:devsync_open_source_collaboration_app/app/app_routes.dart';
import 'package:devsync_open_source_collaboration_app/app/devsync_app.dart';
import 'package:devsync_open_source_collaboration_app/core/di/injection.dart';
import 'package:devsync_open_source_collaboration_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/project_details_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/draggable_match_card.dart';
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

  testWidgets('tapping a match card opens details for that project', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider.value(
        value: getIt<AuthCubit>(),
        child: const DevSyncApp(showSplash: false),
      ),
    );
    await tester.pump();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AppRoutes.feed);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byType(DraggableMatchCard));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Project details'), findsOneWidget);
    expect(find.text('flutter/packages'), findsWidgets);
    expect(find.byType(ProjectDetailsScreen), findsOneWidget);
  });
}
