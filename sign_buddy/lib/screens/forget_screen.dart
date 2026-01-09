import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:sign_buddy/app_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final bool isDark = AppState.isDark.value;
  final LightColor = AppState.LightColor;
  final DarkColor = AppState.DarkColor;

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
      backgroundColor: isDark ? DarkColor: LightColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: isDark ? LightColor:DarkColor),
        title: Text('Forgot Password',style: TextStyle(color: isDark ? LightColor:DarkColor),),
        backgroundColor: isDark ? DarkColor: LightColor,
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
                style: TextStyle(fontSize: 18,color: isDark ? LightColor:DarkColor),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email,color: isDark ? LightColor: DarkColor,),
                  labelStyle: TextStyle(color: isDark? LightColor: DarkColor),
                  border: OutlineInputBorder(),


                ),
                validator: emailValidate,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(backgroundColor: isDark ? LightColor:DarkColor),
                  child: Text('Send Reset Email',style: TextStyle(color: isDark ? DarkColor:LightColor),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
