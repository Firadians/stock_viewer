import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:bni_trading_app/models/stock_model.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  WebSocketChannel? channel;
  late StreamController<String> streamController;
  List<Stock> stocks = [];

  StockBloc() : super(StockInitial()) {
    streamController = StreamController<String>.broadcast();

    channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.eodhistoricaldata.com/ws/crypto?api_token=demo'),
    );

    // Listen to WebSocket stream and dispatch StockDataReceived events
    channel?.stream.listen((data) {
      final jsonData = json.decode(data);
      add(StockDataReceived(jsonData));
    });

    on<SubscribeToStock>(_subscribeToStock);
    on<StockDataReceived>(_handleStockData);
  }

  Future<void> _subscribeToStock(
      SubscribeToStock event, Emitter<StockState> emit) async {
    final subscribeMessage = json.encode({
      "action": "subscribe",
      "symbols": event.symbol,
    });
    channel?.sink.add(subscribeMessage);
  }

  Future<void> _handleStockData(
      StockDataReceived event, Emitter<StockState> emit) async {
    try {
      final stock = Stock.fromJson(event.jsonData);
      stocks.add(stock);

      emit(StockLoaded(stocks));
    } catch (e) {
      emit(StockError('Error processing stock data.'));
    }
  }

  @override
  Future<void> close() {
    channel?.sink.close();
    streamController.close();
    return super.close();
  }
}
