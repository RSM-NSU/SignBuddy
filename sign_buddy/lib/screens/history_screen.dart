import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_buddy/app_state.dart';

import '../lib/database/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> historyList = [];

  @override
  void initState() {
    super.initState();
    initDB();
  }

  Future<void> initDB() async {
    await dbHelper.createDatabase();
    await loadHistory();
  }

  Future<void> loadHistory() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final data = await dbHelper.getHistory(user.uid);

      setState(() {
        historyList = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isDark = AppState.isDark.value;

    return Scaffold(
      backgroundColor: isDark
          ? Color(0xFF212842)
          : Color(0xFFF0E7D5),

      appBar: AppBar(
        backgroundColor: isDark
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
        title: Text(
          'History',
          style: TextStyle(
            color: isDark
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark
              ? Color(0xFFF0E7D5)
              : Color(0xFF212842),
        ),
      ),

      body: historyList.isEmpty
          ? Center(
        child: Text(
          "No History Found",
          style: TextStyle(
            color: isDark
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
      )
          : Padding(
        padding: EdgeInsets.all(15.0),
        child: ListView.builder(
          itemCount: historyList.length,
          itemBuilder: (context, index) {

            final item = historyList[index];

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              color: isDark
                  ? Color(0xFFF0E7D5)
                  : Color(0xFF212842),

              child: ListTile(

                title: Text(
                  "Sign: ${item['predictedSign']}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  ),
                ),
                subtitle: Text(
                  "Confidence: ${(item['confidence'] * 100).toStringAsFixed(1)}%\n"
                      "Time&Date: ${item['dateTime']}",
                  style: TextStyle(
                    color: isDark
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  ),
                ),


              trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  onPressed: () async {

                    await dbHelper.deleteHistory(item['id']);

                    loadHistory();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
