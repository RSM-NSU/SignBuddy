import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:sign_buddy/app_state.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();

  bool _isLoading = false;

  String? nameValidate(String? val) {
    if (val == null || val.trim().isEmpty) return 'Enter name please';
    if (val.trim().length < 4) return 'Minimum 4 characters';
    return null;
  }

  String? emailValidate(String? val) {
    if (val == null || val.trim().isEmpty) return 'Email is required';
    if (!val.contains('@') || !val.contains('.')) return 'Enter valid email';
    return null;
  }

  String? passwordValidate(String? val) {
    if (val == null || val.trim().isEmpty) return 'Password is required';
    if (val.trim().length < 8) return 'Minimum 8 characters';
    return null;
  }

  String? confirmPasswordValidate(String? val) {
    if (val == null || val.trim().isEmpty) return 'Confirm password required';
    if (val.trim() != passwordController.text.trim()) return 'Password not match';
    return null;
  }

  String? phoneValidate(String? val) {
    if (val == null || val.trim().isEmpty) return 'Phone required';
    if (val.trim().length != 11) return 'Phone must be 11 digits';
    if (int.tryParse(val.trim()) == null) return 'Digits only';
    return null;
  }

  String? ageValidate(String? val) {
    if (val == null || val.trim().isEmpty) return 'Age required';
    if (int.tryParse(val.trim()) == null) return 'Digits only';
    return null;
  }

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Flushbar(
        title: 'Success',
        message: 'Account created successfully',
        duration: Duration(seconds: 3),
        backgroundColor: Colors.green,
      ).show(context);

      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      Flushbar(
        title: 'Error',
        message: e.toString(),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.red,
      ).show(context);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppState.isDark.value
          ? Color(0xFF212842)
          : Color(0xFFF0E7D5),

      appBar: AppBar(
        title: Text(
          'Sign Buddy - Signup',
          style: TextStyle(
            color: AppState.isDark.value
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
              ),

              SizedBox(height: 32),

              TextFormField(
                controller: nameController,
                validator: nameValidate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person,
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                validator: emailValidate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email,
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: passwordController,
                validator: passwordValidate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock,
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: confirmPasswordController,
                validator: confirmPasswordValidate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline,
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                validator: phoneValidate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.call,
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                controller: ageController,
                validator: ageValidate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: 'Age',
                  prefixIcon: Icon(Icons.cake,
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                  color: AppState.isDark.value
                      ? Color(0xFF212842)
                      : Color(0xFFF0E7D5),
                )
                    : Text(
                  'Signup',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppState.isDark.value
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  ),
                ),
              ),

              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppState.isDark.value
                            ? Color(0xFFF0E7D5)
                            : Color(0xFF212842),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
