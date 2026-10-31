part of 'requests_cubit.dart';

sealed class RequestsState extends Equatable {
  const RequestsState();

  @override
  List<Object?> get props => [];
}

final class RequestsInitial extends RequestsState {
  const RequestsInitial();
}

final class RequestsLoading extends RequestsState {
  const RequestsLoading();
}

final class RequestsLoaded extends RequestsState {
  const RequestsLoaded({required this.items, this.tab = 0});

  final List<RequestItem> items;
  final int tab;

  List<RequestItem> get visible {
    switch (tab) {
      case 1:
        return items.where((i) => i.type == RequestType.received).toList();
      case 2:
        return items.where((i) => i.type == RequestType.sent).toList();
      default:
        return items;
    }
  }

  RequestsLoaded copyWith({List<RequestItem>? items, int? tab}) {
    return RequestsLoaded(
      items: items ?? this.items,
      tab: tab ?? this.tab,
    );
  }

  @override
  List<Object?> get props => [items, tab];
}

final class RequestsFailure extends RequestsState {
  const RequestsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
