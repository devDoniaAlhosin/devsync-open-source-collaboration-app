import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/collaboration_request.dart';
import '../../domain/usecases/create_request.dart';
import '../../domain/usecases/get_requests.dart';
import '../../domain/usecases/update_request_status.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  RequestsCubit({
    required GetRequests getRequests,
    required CreateRequest createRequest,
    required UpdateRequestStatus updateRequestStatus,
  }) : _getRequests = getRequests,
       _createRequest = createRequest,
       _updateRequestStatus = updateRequestStatus,
       super(const RequestsInitial());

  final GetRequests _getRequests;
  final CreateRequest _createRequest;
  final UpdateRequestStatus _updateRequestStatus;

  Future<void> load() async {
    emit(const RequestsLoading());

    final result = await _getRequests(const NoParams());

    switch (result) {
      case Success(:final data):
        emit(RequestsLoaded(items: data));
      case FailureResult(:final failure):
        final current = state;
        if (current is RequestsLoaded) {
          emit(current.copyWith(actionError: failure.message));
        } else {
          emit(RequestsFailure(failure.message));
        }
    }
  }

  void setTab(int tab) {
    final current = state;
    if (current is! RequestsLoaded) return;

    emit(current.copyWith(tab: tab));
  }

  Future<Result<RequestItem>> create(RequestItem item) async {
    final previous = state;
    if (previous is RequestsLoaded && previous.actionError != null) {
      emit(previous.copyWith(clearActionError: true));
    }

    final result = await _createRequest(CreateRequestParams(item: item));

    switch (result) {
      case Success(:final data):
        final current = state;
        if (current is RequestsLoaded) {
          emit(
            current.copyWith(
              items: [...current.items, data],
              clearActionError: true,
            ),
          );
        }
        return Success(data);

      case FailureResult(:final failure):
        final current = state;
        if (current is RequestsLoaded) {
          emit(current.copyWith(actionError: failure.message));
        } else {
          emit(RequestsFailure(failure.message));
        }
        return FailureResult(failure);
    }
  }

  Future<bool> setStatus(String requestId, RequestStatus status) async {
    final current = state;
    if (current is! RequestsLoaded) return false;
    if (current.actionError != null) {
      emit(current.copyWith(clearActionError: true));
    }

    final result = await _updateRequestStatus(
      UpdateRequestStatusParams(requestId: requestId, status: status),
    );

    switch (result) {
      case Success(:final data):
        final items = [
          for (final request in current.items)
            if (request.id == requestId) data else request,
        ];

        emit(current.copyWith(items: items, clearActionError: true));
        return true;
      case FailureResult(:final failure):
        emit(current.copyWith(actionError: failure.message));
        return false;
    }
  }
}
