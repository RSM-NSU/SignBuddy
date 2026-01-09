import 'package:flutter/material.dart';
import 'package:sign_buddy/app_state.dart';
class HistoryScreen extends StatelessWidget {

  bool isDark = AppState.isDark.value;
  static final LightColor = AppState.LightColor;
  static final DarkColor = AppState.DarkColor;
  final List<String> historyList = [
    'HELLO - 10:31 AM',
    'THANK YOU - 11:15 AM',
    'GOOD MORNING - 08:00 AM',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? DarkColor:LightColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: isDark ? LightColor: DarkColor),
        title: Text('History',style: TextStyle(color: isDark ? LightColor :DarkColor),),
        backgroundColor: isDark ? DarkColor : LightColor,
      ),
      body: Padding(
        padding:  EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: isDark ?  LightColor:DarkColor,
              child: Padding(
                padding:  EdgeInsets.all(15.0),
                child: Text(
                  historyList[index],
                  style: TextStyle(fontSize: 18, color: isDark ?DarkColor:LightColor),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
