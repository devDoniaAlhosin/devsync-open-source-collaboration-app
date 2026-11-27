part of 'insights_cubit.dart';

sealed class InsightsState extends Equatable {
  const InsightsState();

  @override
  List<Object?> get props => [];
}

final class InsightsInitial extends InsightsState {
  const InsightsInitial();
}

final class InsightsLoading extends InsightsState {
  const InsightsLoading();
}

final class InsightsLoaded extends InsightsState {
  const InsightsLoaded(this.data);

  final InsightsData data;

  @override
  List<Object?> get props => [data];
}

final class InsightsFailure extends InsightsState {
  const InsightsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
