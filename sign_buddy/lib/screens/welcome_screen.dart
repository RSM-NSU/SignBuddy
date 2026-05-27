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
    final lightColor = AppState.lightColor;
    final darkColor = AppState.darkColor;

    return Scaffold(
      backgroundColor: isDark ? darkColor : lightColor,
      appBar: AppBar(
        backgroundColor: isDark ? darkColor : lightColor,
        elevation: 0,
        title: Text(
          'Sign Buddy',
          style: TextStyle(
            color: isDark ? lightColor : darkColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Logo icon circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? lightColor : darkColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.sign_language,
                  size: 50,
                  color: isDark ? lightColor : darkColor,
                ),
              ),

              SizedBox(height: 28),

              // App title
              Text(
                "Sign Buddy",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? lightColor : darkColor,
                  letterSpacing: 1.5,
                ),
              ),

              SizedBox(height: 8),

              // Subtitle
              Text(
                "Sign to Text & Speech Translator",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: (isDark ? lightColor : darkColor).withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),

              SizedBox(height: 10),

              // Divider line
              Row(
                children: [
                  Expanded(child: Divider(color: (isDark ? lightColor : darkColor).withOpacity(0.2))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "GET STARTED",
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: (isDark ? lightColor : darkColor).withOpacity(0.4),
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: (isDark ? lightColor : darkColor).withOpacity(0.2))),
                ],
              ),

              SizedBox(height: 28),

              // Login button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 54),
                  backgroundColor: isDark ? lightColor : darkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: isDark ? darkColor : lightColor,
                  ),
                ),
              ),

              SizedBox(height: 14),

              // Signup button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 54),
                  backgroundColor: isDark ? lightColor : darkColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: isDark ? darkColor : lightColor,
                  ),
                ),
              ),

              SizedBox(height: 14),

              // Guest button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 54),
                  backgroundColor: (isDark ? lightColor : darkColor).withOpacity(0.15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: (isDark ? lightColor : darkColor).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, '/guest'),
                child: Text(
                  "Continue as Guest",
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 0.5,
                    color: (isDark ? lightColor : darkColor).withOpacity(0.7),
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