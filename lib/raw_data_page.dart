import 'package:flutter/material.dart';
import 'dart:convert';

class RawDataPage extends StatefulWidget {
  final Stream<String> stream; // Accept the stream in constructor

  RawDataPage({required this.stream});

  @override
  _RawDataPageState createState() => _RawDataPageState();
}

class _RawDataPageState extends State<RawDataPage> {
  List<String> responseList = [];

  @override
  void initState() {
    super.initState();
    // Listen to the broadcast stream
    widget.stream.listen((data) {
      print('Received data: $data'); // Add this line to verify data is received
      setState(() {
        responseList.add(data); // Add each response to the list
        if (responseList.length > 100) {
          responseList.removeAt(0); // Keep the list at a reasonable length
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raw WebSocket Data'),
      ),
      body: responseList.isEmpty
          ? Center(
              child: Text('No data received yet'),
            )
          : ListView.builder(
              itemCount: responseList.length,
              itemBuilder: (context, index) {
                final rawData = responseList[index];
                final jsonData = json.decode(rawData); // Decode to JSON
                return ListTile(
                  title: Text('Symbol: ${jsonData['s']}'),
                  subtitle: Text(
                    'Price: ${jsonData['p']} | Time: ${jsonData['t']}',
                    style: TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
    );
  }
}
