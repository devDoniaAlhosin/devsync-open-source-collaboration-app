import '../error/failures.dart';

sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  );
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return onSuccess(data);
  }
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return onFailure(failure);
  }
}
