import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:bloc/bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'stock_event.dart';
import 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  WebSocketChannel? channel;
  StreamController<String> streamController =
      StreamController<String>.broadcast();
  int? lastBtcSecond;
  int? lastEthSecond;

  List<double> btcPricesInSecond = [];
  List<double> ethPricesInSecond = [];

  List<double> btcDailyDifferencesInSecond = [];
  List<double> ethDailyDifferencesInSecond = [];

  StockBloc() : super(StockState.initial()) {
    channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.eodhistoricaldata.com/ws/crypto?api_token=demo'),
    );

    on<SubscribeToStocksEvent>((event, emit) {
      _subscribeToStocks();
    });

    on<NewStockDataEvent>((event, emit) {
      _processData(event.data, emit);
    });

    // Listen to WebSocket stream and add data to StreamController
    channel?.stream.listen((data) {
      final jsonData = json.decode(data);
      add(NewStockDataEvent(jsonData)); // Add event to the BLoC
    });

    add(SubscribeToStocksEvent()); // Trigger subscription on init
  }

  void _subscribeToStocks() {
    final subscribeMessage = json.encode({
      "action": "subscribe",
      "symbols": "BTC-USD,ETH-USD",
    });
    channel?.sink.add(subscribeMessage);
  }

  void _processData(Map<String, dynamic> data, Emitter<StockState> emit) {
    final double price = double.tryParse(data['p']) ?? 0;
    final double dailyDifference = double.tryParse(data['dd']) ?? 0;
    final double dailyPercentageChange = double.tryParse(data['dc']) ?? 0;
    final int timestamp = data['t'];
    final int currentSecond = timestamp ~/ 1000; // Convert to seconds

    if (_isValidPrice(price)) {
      if (data['s'] == 'BTC-USD') {
        if (lastBtcSecond == null || currentSecond > lastBtcSecond!) {
          if (btcPricesInSecond.isNotEmpty) {
            final avgPrice = btcPricesInSecond.reduce((a, b) => a + b) /
                btcPricesInSecond.length;
            final avgPriceFormatted = double.parse(avgPrice.toStringAsFixed(2));

            final newBtcChartData = List<FlSpot>.from(state.btcChartData)
              ..add(FlSpot(
                  state.btcChartData.length.toDouble(), avgPriceFormatted));

            emit(state.copyWith(
              btcChartData: newBtcChartData,
              btcPrice: avgPriceFormatted,
              btcDailyDifference: dailyDifference,
              btcPercentageChange: dailyPercentageChange,
            ));

            btcPricesInSecond.clear();
          }
          lastBtcSecond = currentSecond;
        }
        btcPricesInSecond.add(price);
      } else if (data['s'] == 'ETH-USD') {
        if (lastEthSecond == null || currentSecond > lastEthSecond!) {
          if (ethPricesInSecond.isNotEmpty) {
            final avgPrice = ethPricesInSecond.reduce((a, b) => a + b) /
                ethPricesInSecond.length;
            final avgPriceFormatted = double.parse(avgPrice.toStringAsFixed(2));

            final newEthChartData = List<FlSpot>.from(state.ethChartData)
              ..add(FlSpot(
                  state.ethChartData.length.toDouble(), avgPriceFormatted));

            emit(state.copyWith(
              ethChartData: newEthChartData,
              ethPrice: avgPriceFormatted,
              ethDailyDifference: dailyDifference,
              ethPercentageChange: dailyPercentageChange,
            ));

            ethPricesInSecond.clear();
          }
          lastEthSecond = currentSecond;
        }
        ethPricesInSecond.add(price);
      }
    }
  }

  bool _isValidPrice(double price) {
    return price.isFinite;
  }

  @override
  Future<void> close() {
    channel?.sink.close();
    streamController.close();
    return super.close();
  }
}
