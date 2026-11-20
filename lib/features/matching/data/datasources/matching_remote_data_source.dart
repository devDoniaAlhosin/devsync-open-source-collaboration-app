import '../models/match_request_model.dart';
import '../models/match_response_model.dart';

abstract class MatchingRemoteDataSource {
  Future<MatchResponseModel> getMatches(MatchRequestModel request);
  void close() {}
}
