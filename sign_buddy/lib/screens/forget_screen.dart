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
            color: AppState.isDark.value
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        iconTheme: IconThemeData(
          color: AppState.isDark.value
              ? Color(0xFFF0E7D5)
              : Color(0xFF212842),
        ),
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'Enter your email to reset password',
                style: TextStyle(
                  fontSize: 18,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
              ),

              SizedBox(height: 15),

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
                    Icons.email,
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842),
                  ),
                  onPressed: resetPassword,
                  child: Text(
                    'Send Reset Email',
                    style: TextStyle(
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
