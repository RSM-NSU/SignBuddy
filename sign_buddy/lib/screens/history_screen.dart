import 'package:flutter/material.dart';
import 'package:sign_buddy/app_state.dart';

class HistoryScreen extends StatelessWidget {

  final List<String> historyList = [
    'HELLO - 10:31 AM',
    'THANK YOU - 11:15 AM',
    'GOOD MORNING - 08:00 AM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppState.isDark.value
          ? Color(0xFF212842)
          : Color(0xFFF0E7D5),

      appBar: AppBar(
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
        title: Text(
          'History',
          style: TextStyle(
            color: AppState.isDark.value
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        iconTheme: IconThemeData(
          color: AppState.isDark.value
              ? Color(0xFFF0E7D5)
              : Color(0xFF212842),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: AppState.isDark.value
                  ? Color(0xFFF0E7D5)
                  : Color(0xFF212842),
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  historyList[index],
                  style: TextStyle(
                    fontSize: 18,
                    color: AppState.isDark.value
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
