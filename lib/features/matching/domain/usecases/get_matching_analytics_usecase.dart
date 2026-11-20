import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/usecases/get_projects.dart';
import '../entities/feedback_record.dart';
import '../entities/matching_analytics.dart';
import '../repositories/matching_profile_repository.dart';
import '../utils/matching_analytics_aggregator.dart';
import 'get_user_feedback_usecase.dart';

/// Loads read-only feedback and supporting profile/project data for analytics.
class GetMatchingAnalyticsUseCase {
  const GetMatchingAnalyticsUseCase({
    required GetUserFeedbackUseCase getUserFeedback,
    required MatchingProfileRepository profileRepository,
    GetProjects? getProjects,
  }) : _getUserFeedback = getUserFeedback,
       _profileRepository = profileRepository,
       _getProjects = getProjects;

  final GetUserFeedbackUseCase _getUserFeedback;
  final MatchingProfileRepository _profileRepository;
  final GetProjects? _getProjects;

  Future<Result<MatchingAnalytics>> call() async {
    final feedbackResult = await _getUserFeedback();
    final feedbackFailure = feedbackResult.fold(
      (failure) => failure,
      (_) => null,
    );
    if (feedbackFailure != null) {
      return FailureResult<MatchingAnalytics>(feedbackFailure);
    }

    final feedback = feedbackResult.fold<List<FeedbackRecord>>(
      (_) => const [],
      (records) => records
          .where((record) => record.isLike || record.isSkip)
          .toList(growable: false),
    );
    if (feedback.isEmpty) {
      return const Success<MatchingAnalytics>(MatchingAnalytics.empty);
    }

    var declaredSkills = const <String>[];
    final profileResult = await _profileRepository.getProfile();
    profileResult.fold((_) {}, (profile) {
      declaredSkills = profile.declaredSkills;
    });

    Map<String, List<String>>? projectSkills;
    final getProjects = _getProjects;
    if (getProjects != null) {
      final projectsResult = await getProjects(const NoParams());
      projectsResult.fold((_) {}, (projects) {
        projectSkills = {
          for (final Project project in projects) project.id: project.techStack,
        };
      });
    }

    return Success(
      MatchingAnalyticsAggregator.aggregate(
        feedback: feedback,
        declaredSkills: declaredSkills,
        projectSkills: projectSkills,
      ),
    );
  }
}
