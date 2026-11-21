import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/requests_repository.dart';

/// Project IDs the current user cannot request again (pending / accepted).
class GetUnavailableProjectIds extends UseCase<Set<String>, NoParams> {
  GetUnavailableProjectIds(this._repository);

  final RequestsRepository _repository;

  @override
  Future<Result<Set<String>>> call(NoParams params) {
    return _repository.getUnavailableProjectIds();
  }
}
