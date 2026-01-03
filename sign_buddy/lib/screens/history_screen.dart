import 'package:flutter/material.dart';
import 'package:sign_buddy/app_state.dart';
class HistoryScreen extends StatelessWidget {

  bool isDark = AppState.isDark.value;

  final List<String> historyList = [
    'HELLO - 10:31 AM',
    'THANK YOU - 11:15 AM',
    'GOOD MORNING - 08:00 AM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ?  Color(0xFF212842):Color(0xFFF0E7D5),
      appBar: AppBar(
        title: Text('History',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
        backgroundColor: isDark ?  Color(0xFF212842):Color(0xFFF0E7D5),
      ),
      body: Padding(
        padding:  EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: isDark ?  Color(0xFFF0E7D5):Color(0xFF212842),
              child: Padding(
                padding:  EdgeInsets.all(15.0),
                child: Text(
                  historyList[index],
                  style: TextStyle(fontSize: 18, color: isDark ? Color(0xFF212842):Color(0xFFF0E7D5)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
