import 'dart:async';
import 'package:bni_trading_app/raw_data_page.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class StockDataPage extends StatefulWidget {
  @override
  _StockDataPageState createState() => _StockDataPageState();
}

class _StockDataPageState extends State<StockDataPage> {
  WebSocketChannel? channel;
  late StreamController<String> streamController; // For broadcast
  List<FlSpot> chartData = []; // List of FlSpots for fl_chart

  // Chart data for BTC and ETH
  List<FlSpot> btcChartData = [];
  double btcPrice = 0.0;
  double btcPercentageChange = 0.0;
  double btcDailyDifference = 0.0;
  int? lastBtcSecond; // Separate last second for BTC

  List<FlSpot> ethChartData = [];
  double ethPrice = 0.0;
  double ethPercentageChange = 0.0;
  double ethDailyDifference = 0.0;
  int? lastEthSecond; // Separate last second for ETH

  double minBtcPrice = double.infinity;
  double maxBtcPrice = double.negativeInfinity;

  double minEthPrice = double.infinity;
  double maxEthPrice = double.negativeInfinity;

  String selectedSymbol = 'BTC-USD'; // Default selected symbol

  @override
  void initState() {
    super.initState();

    // Create a StreamController with a broadcast stream
    streamController = StreamController<String>.broadcast();

    channel = WebSocketChannel.connect(
      Uri.parse('wss://ws.eodhistoricaldata.com/ws/crypto?api_token=demo'),
    );

    // Subscribe to stock symbols
    _subscribeToStocks();

    // Listen to WebSocket stream and add data to StreamController
    channel?.stream.listen((data) {
      streamController.add(data); // Add data to the broadcast stream
      final jsonData = json.decode(data);
      _processData(jsonData);
    });
  }

  void _subscribeToStocks() {
    final subscribeMessage = json.encode({
      "action": "subscribe",
      "symbols": "BTC-USD,ETH-USD",
    });
    channel?.sink.add(subscribeMessage);
  }

  // Helper function to validate the price and prevent non-finite values
  bool _isValidPrice(double price) {
    return price.isFinite;
  }

  void _processData(Map<String, dynamic> data) {
    final double price = double.tryParse(data['p']) ?? 0;
    final double dailyChange = double.tryParse(data['dc']) ?? 0;
    final double dailyDifference = double.tryParse(data['dd']) ?? 0;
    final int timestamp = data['t'];
    final int currentSecond = timestamp ~/ 1000; // Convert to seconds

    if (_isValidPrice(price)) {
      setState(() {
        if (data['s'] == 'BTC-USD') {
          if (lastBtcSecond == null || currentSecond > lastBtcSecond!) {
            // Update BTC data
            btcPrice = price;
            btcPercentageChange = dailyChange;
            btcDailyDifference = dailyDifference;

            // Add BTC price to chart data
            btcChartData.add(FlSpot(btcChartData.length.toDouble(), price));

            // Update min and max prices for BTC
            if (price < minBtcPrice) minBtcPrice = price;
            if (price > maxBtcPrice) maxBtcPrice = price;

            lastBtcSecond = currentSecond; // Sync BTC timestamp
          }
        } else if (data['s'] == 'ETH-USD') {
          if (lastEthSecond == null || currentSecond > lastEthSecond!) {
            // Update ETH data
            ethPrice = price;
            ethPercentageChange = dailyChange;
            ethDailyDifference = dailyDifference;

            // Add ETH price to chart data
            ethChartData.add(FlSpot(ethChartData.length.toDouble(), price));

            // Update min and max prices for ETH
            if (price < minEthPrice) minEthPrice = price;
            if (price > maxEthPrice) maxEthPrice = price;

            lastEthSecond = currentSecond; // Sync ETH timestamp
          }
        }
      });
    }
  }

  @override
  void dispose() {
    channel?.sink.close();
    streamController.close(); // Close the stream controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'James Stewart',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Notification button beside the text
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color.fromARGB(255, 155, 155, 155),
                          width: 1),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications,
                          size: 16,
                          color: Color.fromARGB(255, 130, 130, 130),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RawDataPage(
                                stream: streamController.stream,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildWalletBalance(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedSymbol,
                items: const [
                  DropdownMenuItem(
                    value: 'BTC-USD',
                    child: Text('BTC-USD'),
                  ),
                  DropdownMenuItem(
                    value: 'ETH-USD',
                    child: Text('ETH-USD'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedSymbol = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        if (value % 5 == 0) {
                          return value
                              .toInt()
                              .toString(); // X-Axis: Display every 5th value
                        }
                        return '';
                      },
                      getTextStyles: (context, value) => const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      reservedSize: 22, // Extra space for X-axis labels
                      rotateAngle: 45, // Rotate labels for visibility
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        // Display Y-axis titles every 100 units
                        if (value % 100 == 0) {
                          return value.toInt().toString();
                        }
                        return '';
                      },
                      getTextStyles: (context, value) => const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      reservedSize: 40, // Extra space for Y-axis labels
                    ),
                    topTitles: SideTitles(showTitles: false),
                    rightTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: selectedSymbol == 'BTC-USD'
                          ? btcChartData
                          : ethChartData,
                      isCurved: true,
                      colors: [Color.fromARGB(255, 68, 255, 109)],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [
                          const Color.fromARGB(255, 68, 255, 118)
                              .withOpacity(0.4),
                          const Color.fromARGB(255, 68, 255, 118)
                              .withOpacity(0.1),
                        ],
                        gradientFrom: Offset(0, 0),
                        gradientTo: Offset(0, 1),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  minX: 0,
                  maxX: selectedSymbol == 'BTC-USD'
                      ? btcChartData.isNotEmpty
                          ? btcChartData.length.toDouble()
                          : 60
                      : ethChartData.isNotEmpty
                          ? ethChartData.length.toDouble()
                          : 60,
                  minY: selectedSymbol == 'BTC-USD'
                      ? (minBtcPrice.isFinite ? minBtcPrice - 10 : 0)
                      : (minEthPrice.isFinite
                          ? minEthPrice - 10
                          : 0), // Force valid minY
                  maxY: selectedSymbol == 'BTC-USD'
                      ? (maxBtcPrice.isFinite ? maxBtcPrice + 10 : 100)
                      : (maxEthPrice.isFinite
                          ? maxEthPrice + 10
                          : 100), // Force valid maxY
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: ListView(
                padding: const EdgeInsets.all(8.0),
                children: [
                  _buildWatchlistItem('BTC-USD', 'assets/btc_logo.png',
                      btcPrice, btcDailyDifference, btcPercentageChange),
                  _buildWatchlistItem('ETH-USD', 'assets/eth_logo.png',
                      ethPrice, ethDailyDifference, ethPercentageChange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistItem(
    String name,
    String imagePath,
    double price,
    double dailyDifference,
    double percentageChange,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 16.0),
          Text(
            '${name}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Text(
                    '${dailyDifference > 0 ? '+' : ''}${dailyDifference.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: dailyDifference > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    '${percentageChange > 0 ? '+' : ''}${percentageChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: percentageChange > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildWalletBalance() {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Card(
      color: Color.fromARGB(255, 100, 205, 163),
      elevation: 4, // adds shadow under the card
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Wallet Balance text and value
            Text(
              'Total Wallet Balance',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 8), // Space between title and value
            Text(
              '\$23,582.8',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16), // Space before the profit container

            // Container for Total Profit with semi-transparent background
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white
                    .withOpacity(0.2), // Semi-transparent background
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Profit',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    '\$12,988.32',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildWatchlistItem(String symbol, double price, double dailyDifference,
    double percentageChange) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Asset Logo
          Row(
            children: [
              Image.asset(
                symbol,
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 10),
              // Symbol Text
              const Text(
                'ETHUSD',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Last Price
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Daily Change
          Column(
            children: [
              Text(
                dailyDifference >= 0
                    ? '+\$${dailyDifference.toStringAsFixed(2)}'
                    : '-\$${dailyDifference.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: dailyDifference >= 0 ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
              Text(
                '${percentageChange.toStringAsFixed(2)}%',
                style: TextStyle(
                  color: percentageChange >= 0 ? Colors.green : Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
