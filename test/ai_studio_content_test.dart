import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/liked_matches_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_local_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/datasources/matching_remote_data_source.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_request_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/models/match_response_model.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/match_item.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/matching_preferences.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/entities/user_profile.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/domain/usecases/get_ranked_matches_usecase.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/cubit/matching_cubit.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/screens/ai_matching_studio_screen.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_content.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_scoring_card.dart';
import 'package:devsync_open_source_collaboration_app/features/matching/presentation/widgets/ai_studio_suggested_matches_card.dart';

class _CapturingRemoteDataSource implements MatchingRemoteDataSource {
  final List<MatchRequestModel> capturedRequests = [];

  @override
  Future<MatchResponseModel> getMatches(MatchRequestModel request) async {
    capturedRequests.add(request);
    return const MatchResponseModel(matches: [], promptVersion: 'v1');
  }

  @override
  void close() {}
}

const _testProfile = UserProfile(
  uid: 'studio-user-001',
  declaredSkills: ['Flutter', 'Dart', 'Firebase'],
  githubLanguages: {'Dart': 90},
  publicRepoCount: 10,
  totalContributions: 150,
);

MatchingCubit _createCubit(_CapturingRemoteDataSource remoteDataSource) {
  final repo = MatchingRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: InMemoryMatchingLocalDataSource(),
  );
  return MatchingCubit(
    repository: repo,
    likedMatchesDataSource: InMemoryLikedMatchesDataSource(),
    getRankedMatchesUseCase: GetRankedMatchesUseCase(repo),
    profile: _testProfile,
  );
}

void main() {
  group('AI Studio', () {
    testWidgets('studio synchronizes external prompts without emitting edits', (
      tester,
    ) async {
      final edits = <String>[];
      Widget buildStudio(String prompt) => MaterialApp(
        home: Scaffold(
          body: AiStudioContent(
            preferences: MatchingPreferences(prompt: prompt),
            matches: const [],
            availableTags: const [],
            isGenerating: false,
            onPromptChanged: edits.add,
            onTagToggled: (_) {},
            onGenerateMatches: () {},
            onViewProjectDetails: (_) {},
            onExploreAnalytics: () {},
          ),
        ),
      );
      await tester.pumpWidget(buildStudio('Initial prompt'));
      await tester.enterText(find.byType(TextField), 'Edited prompt');
      expect(edits, ['Edited prompt']);
      await tester.pumpWidget(buildStudio('Refined prompt'));
      expect(find.text('Refined prompt'), findsOneWidget);
      expect(edits, ['Edited prompt']);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    });

    test(
      'preferences saving: updating prompt and tags saves MatchingPreferences in cubit',
      () {
        final remote = _CapturingRemoteDataSource();
        final cubit = _createCubit(remote);

        cubit.updatePrompt('looking for beginner friendly mobile apps');
        cubit.toggleTag('Flutter');
        cubit.toggleTag('Dart');

        expect(
          cubit.state.preferences.prompt,
          'looking for beginner friendly mobile apps',
        );
        expect(
          cubit.state.preferences.selectedTags,
          containsAll(['Flutter', 'Dart']),
        );

        // savePreferences also saves directly
        const newPrefs = MatchingPreferences(
          prompt: 'direct save prompt',
          selectedTags: {'Firebase'},
        );
        cubit.savePreferences(newPrefs);
        expect(cubit.state.preferences.prompt, 'direct save prompt');
        expect(cubit.state.preferences.selectedTags, {'Firebase'});

        cubit.close();
      },
    );

    test(
      'prompt sending: generateMatches sends prompt while default feed load does not',
      () async {
        final remote = _CapturingRemoteDataSource();
        final cubit = _createCubit(remote);

        cubit.updatePrompt('AI prompt from studio');
        cubit.toggleTag('Flutter');

        // 1. Default feed load (loadInitialData) must NOT send prompt/tags (untouched)
        await cubit.loadInitialData();
        expect(remote.capturedRequests.length, 1);
        expect(remote.capturedRequests[0].prompt, isNull);
        expect(remote.capturedRequests[0].tags, isNull);

        // 2. Studio generate (generateMatches) sends prompt and tags
        await cubit.generateMatches();
        expect(remote.capturedRequests.length, 2);
        expect(remote.capturedRequests[1].prompt, 'AI prompt from studio');
        expect(remote.capturedRequests[1].tags, contains('Flutter'));

        cubit.close();
      },
    );

    testWidgets(
      'scoring copy: displays AI model or Heuristic fallback without invented percentages',
      (tester) async {
        // 1. AI model copy
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AiStudioScoringCard(
                source: MatchSource.ai,
                onExploreAnalytics: () {},
              ),
            ),
          ),
        );
        expect(find.text('How scoring works'), findsOneWidget);
        expect(find.text('Scoring method: AI Model'), findsOneWidget);
        expect(find.textContaining('AI matching service'), findsOneWidget);
        // Ensure no invented percentages are displayed
        expect(find.textContaining('%'), findsNothing);

        // 2. Heuristic fallback copy
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AiStudioScoringCard(
                source: MatchSource.fallback,
                onExploreAnalytics: () {},
              ),
            ),
          ),
        );
        expect(
          find.text('Scoring method: Heuristic (Deterministic Fallback)'),
          findsOneWidget,
        );
        expect(find.textContaining('deterministic overlap'), findsOneWidget);
        expect(find.textContaining('%'), findsNothing);
      },
    );

    testWidgets(
      'fallback mirror: suggested matches mirrors feed banner, score, reason, and tags',
      (tester) async {
        const fallbackMatch = MatchItem(
          projectId: 'p1',
          projectName: 'devsync/backend',
          description: 'Open source collaboration hub backend',
          githubUrl: 'https://github.com/devsync/backend',
          neededSkills: ['Dart', 'PostgreSQL'],
          score: 85,
          reason: 'Overlapping skills: Dart',
          isFallback: true,
          source: MatchSource.fallback,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AiStudioSuggestedMatchesCard(
                  matches: const [fallbackMatch],
                  onViewProjectDetails: (_) {},
                ),
              ),
            ),
          ),
        );

        // Mirrored fallback banner
        expect(find.text('Basic skill match — AI unavailable'), findsOneWidget);
        // Mirrored score
        expect(find.text('85%'), findsOneWidget);
        // Mirrored reason
        expect(find.text('Overlapping skills: Dart'), findsOneWidget);
        // Mirrored needed skills tags
        expect(find.text('Dart'), findsOneWidget);
        expect(find.text('PostgreSQL'), findsOneWidget);
        // Skill-based match label
        expect(find.text('Skill-based match'), findsOneWidget);
      },
    );

    testWidgets('AiMatchingStudioScreen renders and triggers generate', (
      tester,
    ) async {
      final remote = _CapturingRemoteDataSource();
      final cubit = _createCubit(remote);

      await tester.pumpWidget(
        MaterialApp(home: AiMatchingStudioScreen(cubit: cubit)),
      );
      await tester.pump();

      expect(find.text('AI Studio'), findsOneWidget);
      expect(find.text('Match\npreferences'), findsOneWidget);
      expect(find.text('Generate matches'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Testing prompt');
      await tester.tap(find.text('Generate matches'));
      await tester.pump();

      expect(cubit.state.preferences.prompt, 'Testing prompt');
      cubit.close();
    });
  });
}
