import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sign_buddy/app_state.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isDark = AppState.isDark.value;
  static final LightColor = AppState.LightColor;
  static final DarkColor = AppState.DarkColor;

  @override
  void initState() {
    super.initState();
    listenAuth();
  }

  void listenAuth() async {

    await Future.delayed(Duration(seconds: 3));

    FirebaseAuth.instance.authStateChanges().listen((User? user) {

      if (!mounted) return;

      if (user == null) {
        Navigator.pushReplacementNamed(context, '/welcome');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: isDark ? DarkColor : LightColor,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              'Sign Buddy',
              style: TextStyle(
                fontSize: 50,
                color: isDark ? LightColor : DarkColor,
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Sign to Text & Speech Translator',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? LightColor : DarkColor,
              ),
            ),

            SizedBox(height: 10),

            Lottie.asset(
              'assets/animations/loading.json',
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
