import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sign_buddy/screens/edit_profile_screen.dart';
import 'screens/home_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/history_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart';
import 'screens/forget_screen.dart';
import 'app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ValueListenableBuilder<bool>(
      valueListenable: AppState.isDark,
      builder: (context, isDark, _) {
        return SignBuddyApp(isDark: isDark);
      },
    ), );
}

class SignBuddyApp extends StatelessWidget {
  final bool isDark;

  const SignBuddyApp({super.key,required this.isDark});
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
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/forget':(context)=>ForgotPasswordScreen(),
        '/edit':(context)=>EditProfileScreen(),

      },
    );
  }
}
