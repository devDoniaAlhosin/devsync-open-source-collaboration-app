import '../result/result.dart';

abstract class UseCase<T, P> {
  Future<Result<T>> call(P params);
}

abstract class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

class NoParams {
  const NoParams();
}
