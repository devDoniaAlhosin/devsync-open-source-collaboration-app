import '../models/match_request_model.dart';
import '../models/match_response_model.dart';

/// Contract for fetching match recommendations from the backend.
abstract class MatchingRemoteDataSource {
  Future<MatchResponseModel> getMatches(MatchRequestModel request);
  void close() {}
}
