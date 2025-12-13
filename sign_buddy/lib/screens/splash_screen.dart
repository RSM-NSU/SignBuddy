import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 8), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Text(
              'Sign Buddy',
              style: GoogleFonts.permanentMarker(
                fontSize: 50,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Sign to Text & Speech Translator',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
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
