import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final gradientColors = isDark
        ? [Colors.grey.shade800, Colors.grey.shade900]
        : [Colors.deepPurple.shade200, Colors.deepPurple.shade600];
    final textColor = isDark ? Colors.white : Colors.white;
    final subTextColor = isDark ? Colors.white70 : Colors.white70;
    final buttonColor = isDark ? Colors.deepPurple[700] : Colors.deepPurple[900];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Buddy',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'User'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Dark/Light Theme'),
              trailing: Switch(
                value: isDark,
                onChanged: (val) {
                  setState(() {
                    isDark = val;
                  });
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Lottie.asset(
              'assets/animations/Handshake Loop.json',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              repeat: true,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Sign Buddy',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Sign to Text & Speech Translator',
              style: TextStyle(fontSize: 16, color: subTextColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 6,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 28, color: Colors.white),
                  SizedBox(width: 15),
                  Text(
                    'Start Translation',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 6,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 28, color: Colors.white),
                  SizedBox(width: 15),
                  Text(
                    'View History',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
    );
  }
}
