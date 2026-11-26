import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/insights_data.dart';
import '../../domain/usecases/get_insights.dart';

part 'insights_state.dart';

class InsightsCubit extends Cubit<InsightsState> {
  InsightsCubit({required GetInsights getInsights})
    : _getInsights = getInsights,
      super(const InsightsInitial());

  final GetInsights _getInsights;

  Future<void> load() async {
    if (state is InsightsLoading) return; // ignore double taps on Retry
    emit(const InsightsLoading());

    final result = await _getInsights(const NoParams());

    // The user may have left the screen while GitHub was answering.
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(InsightsLoaded(data));
      case FailureResult(:final failure):
        emit(InsightsFailure(failure.message));
    }
  }
}
