import '../models/match_item_model.dart';
import '../models/match_request_model.dart';
import '../models/match_response_model.dart';
import '../models/matching_analytics_model.dart';

/// Calls the matching Cloud Function and returns parsed results.
///
/// Production implementation uses HTTP to call the DevSync backend API
/// with Firebase authentication. For tests, use MockMatchingRemoteDataSource
/// from test/features/matching/mocks/.
abstract class MatchingRemoteDataSource {
  /// Send [request] to the Cloud Function and return the parsed response.
  Future<MatchResponseModel> getMatches(MatchRequestModel request);

  /// Generate dynamic matches for the given custom natural-language [prompt] and [tags].
  Future<List<MatchItemModel>> generateMatchesWithPrompt({
    required String prompt,
    Set<String>? tags,
  });

  /// Retrieve recommendation analytics and transparency metrics.
  Future<MatchingAnalyticsModel> getAnalytics();
}
