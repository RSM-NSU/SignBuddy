import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:sign_buddy/app_state.dart';

class LoginScreen extends StatefulWidget {


  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isDark = AppState.isDark.value;

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? emailValidate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? passwordValidate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password Required';
    }
    if (value.length < 8) {
      return 'Minimum 8 characters';
    }
    return null;
  }

  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Flushbar(
          title: 'Login Successful',
          message: 'Welcome ${emailController.text}',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(Icons.check_circle, color: Colors.white),
        ).show(context);

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        Flushbar(
          title: 'Login Failed',
          message: e.toString(),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(Icons.error, color: Colors.white),
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ?  Color(0xFF212842): Color(0xFFF0E7D5),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Text(
                  'Sign Buddy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
                ),
                SizedBox(height: 40),


                TextFormField(
                  controller: emailController,
                  validator: emailValidate,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@gmail.com',
                    prefixIcon: Icon(Icons.email, color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842),),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 20),


                TextFormField(
                  controller: passwordController,
                  validator: passwordValidate,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock, color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842),),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forget');
                    },
                    child: Text('Forgot Password?',
                        style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842))),
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed:() {
                  loginUser();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: isDark ?  Color(0xFF212842) : Color(0xFFF0E7D5) ),
                  ),
                ),
                SizedBox(height: 20),


                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",style : TextStyle(
                    color: isDark ? Color(0xFFF0E7D5): Color(0xFF212842))),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text('Sign Up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Color(0xFFF0E7D5): Color(0xFF212842)),
                    )
                    )],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
