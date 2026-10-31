import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/collaboration_request.dart';
import '../../domain/usecases/get_requests.dart';
import '../../domain/usecases/update_request_status.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  RequestsCubit({
    required this._getRequests,
    required this._updateRequestStatus,
  }) : super(const RequestsInitial());

  final GetRequests _getRequests;
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

  Future<void> setStatus(RequestItem item, RequestStatus status) async {
    final current = state;
    if (current is! RequestsLoaded) return;

    final result = await _updateRequestStatus(
      UpdateRequestStatusParams(item: item, status: status),
    );
    switch (result) {
      case Success(:final data):
        final items = [
          for (final r in current.items)
            if (r.title == item.title &&
                r.type == item.type &&
                r.displayName == item.displayName)
              data
            else
              r,
        ];
        emit(current.copyWith(items: items));
      case FailureResult(:final failure):
        emit(RequestsFailure(failure.message));
    }
  }
}
