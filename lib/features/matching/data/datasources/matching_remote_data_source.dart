import '../models/match_request_model.dart';
import '../models/match_response_model.dart';

/// Calls the matching Cloud Function and returns parsed results.
///
/// Production implementation uses HTTP to call the DevSync backend API
/// with Firebase authentication. For tests, use MockMatchingRemoteDataSource
/// from test/features/matching/mocks/.
abstract class MatchingRemoteDataSource {
  /// Send [request] to the Cloud Function and return the parsed response.
  Future<MatchResponseModel> getMatches(MatchRequestModel request);

  /// Release transport resources when the owning repository is disposed.
  void close() {}
}
