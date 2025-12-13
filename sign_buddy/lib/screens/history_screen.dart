import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  // Dummy history data
  final List<String> historyList = [
    'HELLO - 10:30 AM',
    'THANK YOU - 11:15 AM',
    'GOOD MORNING - 08:00 AM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  historyList[index],
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple[900]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
