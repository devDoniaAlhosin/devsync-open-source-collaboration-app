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
    required this._getRequests,
    required this._createRequest,
    required this._updateRequestStatus,
  }) : super(const RequestsInitial());

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
        emit(RequestsFailure(failure.message));
    }
  }

  void setTab(int tab) {
    final current = state;
    if (current is! RequestsLoaded) return;

    emit(current.copyWith(tab: tab));
  }

  Future<RequestItem?> create(RequestItem item) async {
    final result = await _createRequest(CreateRequestParams(item: item));

    switch (result) {
      case Success(:final data):
        final current = state;
        if (current is RequestsLoaded) {
          emit(current.copyWith(items: [...current.items, data]));
        }
        return data;

      case FailureResult(:final failure):
        emit(RequestsFailure(failure.message));
        return null;
    }
  }

  Future<void> setStatus(String requestId, RequestStatus status) async {
    final current = state;
    if (current is! RequestsLoaded) return;

    final result = await _updateRequestStatus(
      UpdateRequestStatusParams(requestId: requestId, status: status),
    );

    switch (result) {
      case Success(:final data):
        final items = [
          for (final request in current.items)
            if (request.id == requestId) data else request,
        ];

        emit(current.copyWith(items: items));

      case FailureResult(:final failure):
        emit(RequestsFailure(failure.message));
    }
  }
}
