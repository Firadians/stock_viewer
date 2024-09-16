import 'package:fl_chart/fl_chart.dart';

class StockState {
  final List<FlSpot> btcChartData;
  final List<FlSpot> ethChartData;
  final double btcPrice;
  final double ethPrice;
  final double btcPercentageChange;
  final double ethPercentageChange;
  final double btcDailyDifference;
  final double ethDailyDifference;

  StockState({
    required this.btcChartData,
    required this.ethChartData,
    required this.btcPrice,
    required this.ethPrice,
    required this.btcPercentageChange,
    required this.ethPercentageChange,
    required this.btcDailyDifference,
    required this.ethDailyDifference,
  });

  factory StockState.initial() {
    return StockState(
      btcChartData: [],
      ethChartData: [],
      btcPrice: 0.0,
      ethPrice: 0.0,
      btcPercentageChange: 0.0,
      ethPercentageChange: 0.0,
      btcDailyDifference: 0.0,
      ethDailyDifference: 0.0,
    );
  }

  StockState copyWith({
    List<FlSpot>? btcChartData,
    List<FlSpot>? ethChartData,
    double? btcPrice,
    double? ethPrice,
    double? btcPercentageChange,
    double? ethPercentageChange,
    double? btcDailyDifference,
    double? ethDailyDifference,
  }) {
    return StockState(
      btcChartData: btcChartData ?? this.btcChartData,
      ethChartData: ethChartData ?? this.ethChartData,
      btcPrice: btcPrice ?? this.btcPrice,
      ethPrice: ethPrice ?? this.ethPrice,
      btcPercentageChange: btcPercentageChange ?? this.btcPercentageChange,
      ethPercentageChange: ethPercentageChange ?? this.ethPercentageChange,
      btcDailyDifference: btcDailyDifference ?? this.btcDailyDifference,
      ethDailyDifference: ethDailyDifference ?? this.ethDailyDifference,
    );
  }
}
