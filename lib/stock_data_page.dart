import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:bni_trading_app/bloc/stock_bloc.dart';
import 'package:bni_trading_app/bloc/stock_state.dart';

class StockDataPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StockBloc(),
      child: SafeArea(
        child: Scaffold(
          body: BlocBuilder<StockBloc, StockState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      _buildIntroductionSection(),
                      SizedBox(height: 20),
                      // Wallet Balance Section
                      _buildWalletBalanceSection(),

                      SizedBox(height: 20),
                      // BTC Data Display
                      _buildStockDataSection(
                        label: 'BTC Price',
                        price: state.btcPrice,
                        percentageChange: state.btcPercentageChange,
                        dailyDifference: state.btcDailyDifference,
                        chartData: state.btcChartData,
                        color: Colors.orange,
                      ),

                      SizedBox(height: 20),
                      // ETH Data Display
                      _buildStockDataSection(
                        label: 'ETH Price',
                        price: state.ethPrice,
                        percentageChange: state.ethPercentageChange,
                        dailyDifference: state.ethDailyDifference,
                        chartData: state.ethChartData,
                        color: Colors.blue,
                      ),

                      SizedBox(height: 20),
                      // Watchlist Section
                      _buildWatchlistItem(
                          'BTC-USD',
                          'assets/btc_logo.png',
                          state.btcPrice,
                          state.btcDailyDifference,
                          state.btcPercentageChange),
                      _buildWatchlistItem(
                          'ETH-USD',
                          'assets/eth_logo.png',
                          state.ethPrice,
                          state.ethDailyDifference,
                          state.ethPercentageChange),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  //Intro Section
  Widget _buildIntroductionSection() {
    return Row(
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // Notification button beside the text
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color.fromARGB(255, 155, 155, 155), width: 1),
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
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  // Wallet Balance Section Widget
  Widget _buildWalletBalanceSection() {
    return Card(
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

// Stock Data Section (for BTC and ETH)
Widget _buildStockDataSection({
  required String label,
  required double price,
  required double percentageChange,
  required double dailyDifference,
  required List<FlSpot> chartData,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      Text(
        'Current Price: \$${price.toStringAsFixed(2)}',
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
      SizedBox(height: 5),
      Text(
        'Change: ${percentageChange.toStringAsFixed(2)}% | Daily Difference: ${dailyDifference.toStringAsFixed(2)}',
        style: TextStyle(
            fontSize: 14,
            color: percentageChange >= 0 ? Colors.green : Colors.red),
      ),
      SizedBox(height: 10),
      _buildLineChart(chartData, color),
    ],
  );
}

// Line Chart Widget (BTC/ETH charts)
Widget _buildLineChart(List<FlSpot> spots, Color color) {
  return SizedBox(
    height: 200,
    child: LineChart(
      LineChartData(
        gridData: FlGridData(
          drawVerticalLine: false, // Hide vertical grid lines
          drawHorizontalLine: true, // Show horizontal grid lines
          horizontalInterval: 10, // Space between horizontal lines
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1), // Horizontal grid color
              strokeWidth: 1, // Grid line thickness
            );
          },
        ),
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
              color: Colors.grey, // Bottom axis label color
            ),
          ),
          leftTitles: SideTitles(
            showTitles: true,
            getTextStyles: (context, value) => const TextStyle(
              fontSize: 10,
              color: Colors.grey, // Y-Axis label color
            ),
            reservedSize: 40, // Reserve space for Y-axis labels
          ),
          topTitles: SideTitles(showTitles: false), // Hide top axis
          rightTitles: SideTitles(showTitles: false), // Hide right axis
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.grey.withOpacity(0.2), // Border color for the chart
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            colors: [color], // Line color
            barWidth: 3,
            isStrokeCapRound: true, // Smooth line caps
            belowBarData: BarAreaData(
              show: true,
              colors: [
                color.withOpacity(0.4), // Gradient color from the line
                color.withOpacity(0.1), // Gradient color to the bottom
              ],
              gradientFrom: Offset(0, 0), // Start of gradient
              gradientTo: Offset(0, 1), // End of gradient
            ),
            dotData: FlDotData(show: false), // Hide dots on the line
          ),
        ],
        minX: 0,
        maxX: spots.isNotEmpty ? spots.length.toDouble() : 60, // X-axis range
        minY: spots.isNotEmpty
            ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) - 10
            : 0, // Min Y-axis
        maxY: spots.isNotEmpty
            ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10
            : 100, // Max Y-axis
      ),
    ),
  );
}
