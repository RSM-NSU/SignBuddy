import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:sign_buddy/app_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  String? emailValidate(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  void resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      Flushbar(
        title: 'Email Sent',
        message: 'Check your inbox for the reset link',
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ).show(context).then((_) {
        if (mounted) Navigator.pop(context);
      });

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Flushbar(
        title: 'Error',
        message: e.message ?? 'Something went wrong',
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    } catch (e) {
      if (!mounted) return;
      Flushbar(
        title: 'Error',
        message: e.toString(),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppState.isDark.value
          ? Color(0xFF212842)
          : Color(0xFFF0E7D5),

      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppState.isDark.value
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppState.isDark.value
              ? Color(0xFFF0E7D5)
              : Color(0xFF212842),
        ),
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 30),

              // ── Lock Icon
              CircleAvatar(
                radius: 45,
                backgroundColor: AppState.isDark.value
                    ? Color(0xFFF0E7D5).withOpacity(0.1)
                    : Color(0xFF212842).withOpacity(0.1),
                child: Icon(
                  Icons.lock_reset,
                  size: 45,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
              ),

              SizedBox(height: 24),

              // ── Title
              Text(
                'Reset Password',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Enter your email to receive a reset link',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5).withOpacity(0.5)
                      : Color(0xFF212842).withOpacity(0.5),
                ),
              ),

              SizedBox(height: 36),

              // ── Email Field
              TextFormField(
                controller: emailController,
                validator: emailValidate,
                style: TextStyle(
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842),
                  ),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      width: 2,
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                ),
              ),

              SizedBox(height: 28),

              // ── Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: resetPassword,
                  child: Text(
                    'Send Reset Email',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppState.isDark.value
                          ? Color(0xFF212842)
                          : Color(0xFFF0E7D5),
                    ),
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