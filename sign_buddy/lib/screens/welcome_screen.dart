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
    print(isDark);
    final lightColor = AppState.lightColor;
    final darkColor = AppState.darkColor;

    return Scaffold(
      backgroundColor: isDark ? darkColor : lightColor,

      appBar: AppBar(
        backgroundColor: isDark ? darkColor : lightColor,
        title: Text(
          'Welcome To Sign Buddy',
          style: TextStyle(
            color: isDark ? lightColor : darkColor,
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
                  color: isDark ? lightColor : darkColor,
                ),
              ),

              SizedBox(height: 15),

              Text(
                "Sign to Text & Speech Translator",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? lightColor : darkColor,
                ),
              ),

              SizedBox(height: 50),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: isDark ? lightColor : darkColor,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? darkColor : lightColor,
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: isDark ? lightColor : darkColor,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/signup');
                },
                child: Text(
                  "Signup",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? darkColor : lightColor,
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: isDark ? lightColor : darkColor,
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/guest');
                },
                child: Text(
                  "Continue as Guest",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? darkColor : lightColor,
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
