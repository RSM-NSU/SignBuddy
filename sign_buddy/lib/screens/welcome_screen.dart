import 'package:flutter/material.dart';
import 'package:sign_buddy/app_state.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  Widget build(BuildContext context) {

    bool isDark = AppState.isDark.value;
    final LightColor = AppState.LightColor;
    final DarkColor = AppState.DarkColor;

    return Scaffold(
      backgroundColor: isDark ? DarkColor : LightColor,

      appBar: AppBar(
        backgroundColor: isDark ? DarkColor : LightColor,
        title: Text(
          'Welcome To Sign Buddy',
          style: TextStyle(
            color: isDark ? LightColor : DarkColor,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "Sign Buddy",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: isDark ? LightColor : DarkColor,
                ),
              ),

              SizedBox(height: 15),

              Text(
                "Sign to Text & Speech Translator",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? LightColor : DarkColor,
                ),
              ),

              SizedBox(height: 50),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: isDark ? LightColor : DarkColor,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? DarkColor : LightColor,
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: isDark ? LightColor : DarkColor,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: Text(
                  "Signup",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? DarkColor : LightColor,
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: isDark ? LightColor : DarkColor,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/guest');
                },
                child: Text(
                  "Continue as Guest",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? DarkColor : LightColor,
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
