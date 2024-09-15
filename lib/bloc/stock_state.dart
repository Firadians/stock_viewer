import 'package:bni_trading_app/models/stock_model.dart';

abstract class StockState {}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<Stock> stocks;

  StockLoaded(this.stocks);
}

class StockError extends StockState {
  final String message;

  StockError(this.message);
}
