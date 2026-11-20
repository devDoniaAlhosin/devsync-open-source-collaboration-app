# MATCHING_STATE.md
Status: All tasks T0-T11 completed on `feature/matching`. Schema compatibility added for nested `profile` map.
Map: lib/features/matching/ (Result/Failure: MatchingFailure & Result<T>; GetIt: lib/core/di/injection.dart; Repositories: matching_repository_impl.dart, firestore_feedback_repository.dart, firestore_matching_profile_repository.dart; Analytics: matching_analytics_aggregator.dart; Cubit: matching_cubit.dart; Screens: match_feed_screen, ai_analytics_screen, ai_matching_studio_screen, prompt_quality_screen; Tests: test/features/matching/, test/ai_studio_content_test.dart, test/matching_clean_architecture_test.dart).
Contract: POST https://devsync-backend-two.vercel.app/matches/generate. Auth: Bearer <Firebase ID token>. Req: {uid, declaredSkills, githubLanguages, publicRepoCount, totalContributions, bio?, topRepositories, projects?, prompt?, tags?}. Res: {matches: [{projectId, projectName, description, githubUrl, neededSkills, score, reason, isFallback?}], promptVersion, fallback?}.
Candidate projects: `ProjectModel` maps `techStack` -> `neededSkills` in request.
User profile: reads skills from `data['profile']['skills']` (nested map from Profile feature and ERD), `data['skills']`, and `data['declaredSkills']`.
Decisions:
- T1: HTTP timeout 20s.
- T2: GetIt setup already complete (NOT REQUIRED).
- T3: MatchingStatus enum, retry(), feed UI states, ValidationFailure.
- T4: Real request & response validation with drop of unknown projectIds.
- T5: Deterministic fallback with skill-overlap scoring.
- T6: Read-only feedback reader (FeedbackRecord, FirestoreFeedbackRepository, GetUserFeedbackUseCase).
- T7: Real analytics aggregation from feedback, removed demo wiring.
- T8: AI Studio preferences save, prompt/tags sending on generateMatches, scoring card copy, suggested matches mirror.
- T9: Prompt quality screen shows unavailable state, no demo data; promptVersion added to FeedbackRecord.
- T10: Swept dead MockMatchingRemoteDataSource class; no UnimplementedErrors; no demo data in production.
- T11: Final format, verify, and clean status.
- Post-T11 Fix: Support nested `profile` map in `FirestoreMatchingProfileRepository` so skills in `users/{uid}.profile.skills` are read properly.
Tests: 116/116 passed.
