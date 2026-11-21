import '../../../../core/usecase/usecase.dart';
import '../repositories/requests_repository.dart';

class WatchPendingReceivedRequests implements StreamUseCase<bool, NoParams> {
  WatchPendingReceivedRequests(this._repository);

  final RequestsRepository _repository;

  @override
  Stream<bool> call(NoParams params) => _repository.watchHasPendingReceived();
}
