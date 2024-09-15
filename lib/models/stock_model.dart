class Stock {
  final String symbol;
  final double price;
  final double dailyDifference;
  final double percentageChange;

  Stock({
    required this.symbol,
    required this.price,
    required this.dailyDifference,
    required this.percentageChange,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    final double price = double.tryParse(json['p']) ?? 0;
    final double dailyChange = double.tryParse(json['dc']) ?? 0;
    final double dailyDifference = double.tryParse(json['dd']) ?? 0;
    return Stock(
      symbol: json['s'],
      price: price,
      dailyDifference: dailyDifference,
      percentageChange: dailyChange,
    );
  }
}
