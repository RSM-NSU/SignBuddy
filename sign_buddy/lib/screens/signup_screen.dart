import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:sign_buddy/app_state.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  bool isDark = AppState.isDark.value;
  static final lightColor = AppState.lightColor;
  static final darkColor = AppState.darkColor;

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
      backgroundColor: isDark ? darkColor : lightColor,

      appBar: AppBar(
        backgroundColor: isDark ? darkColor : lightColor,
        foregroundColor: isDark ? lightColor : darkColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/welcome');
          },
        ),
        title: Text(
          'Sign Buddy - Signup',
          style: TextStyle(
            color: isDark ? lightColor : darkColor,
          ),
        ),
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
                  color: isDark ? lightColor : darkColor,
                ),
              ),

              SizedBox(height: 32),

              buildField(nameController, 'Full Name', Icons.person, nameValidate),
              SizedBox(height: 16),

              buildField(emailController, 'Email', Icons.email, emailValidate),
              SizedBox(height: 16),

              buildField(passwordController, 'Password', Icons.lock, passwordValidate, obscure: true),
              SizedBox(height: 16),

              buildField(confirmPasswordController, 'Confirm Password', Icons.lock_outline, confirmPasswordValidate, obscure: true),
              SizedBox(height: 16),

              buildField(phoneController, 'Phone', Icons.call, phoneValidate),
              SizedBox(height: 16),

              buildField(ageController, 'Age', Icons.cake, ageValidate),

              SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? lightColor : darkColor,
                  foregroundColor: isDark ? darkColor : lightColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                  color: isDark ? darkColor : lightColor,
                )
                    : Text(
                  'Signup',
                  style: TextStyle(fontSize: 18),
                ),
              ),

              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: isDark ? lightColor : darkColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? lightColor : darkColor,
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

  Widget buildField(
      TextEditingController controller,
      String label,
      IconData icon,
      String? Function(String?) validator, {
        bool obscure = false,
      }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? lightColor : darkColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}