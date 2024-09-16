import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubscribeToStocksEvent extends StockEvent {}

class NewStockDataEvent extends StockEvent {
  final Map<String, dynamic> data;

  NewStockDataEvent(this.data);

  @override
  List<Object?> get props => [data];
}
