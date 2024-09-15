abstract class StockEvent {}

class SubscribeToStock extends StockEvent {
  final String symbol;

  SubscribeToStock(this.symbol);
}

class StockDataReceived extends StockEvent {
  final Map<String, dynamic> jsonData;

  StockDataReceived(this.jsonData);
}
