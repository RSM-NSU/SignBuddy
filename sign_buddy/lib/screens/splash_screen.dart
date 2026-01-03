import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_buddy/app_state.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isDark = AppState.isDark.value;
  @override
  void initState() {
    super.initState();
    checkLogin();
  }


  void checkLogin() async {
    await Future.delayed(Duration(seconds: 3));

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ?  Color(0xFF212842):Color(0xFFF0E7D5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Text(
              'Sign Buddy',
              style: TextStyle(
                fontSize: 50,
                color: isDark ?  Color(0xFFF0E7D5):Color(0xFF212842),
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Sign to Text & Speech Translator',
              style: TextStyle(
                fontSize: 18,
                color: isDark ?  Color(0xFFF0E7D5):Color(0xFF212842),
              ),
            ),
            SizedBox(height: 10,),
            Lottie.asset(
              'assets/animations/loading.json', // <-- your Lottie JSON file
              width: 390,
              height: 200,
              fit: BoxFit.cover,
              repeat: true,
            ),
          ],
        ),
      ),
    );
  }
}
