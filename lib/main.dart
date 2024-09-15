import 'package:flutter/material.dart';
import 'package:bni_trading_app/stock_data_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockDataPage(),
    );
  }
}
