import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(SignBuddyApp());
}

class SignBuddyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Buddy',
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/camera': (context) => CameraScreen(),
        '/history': (context) => HistoryScreen(),
      },
    );
  }
}
