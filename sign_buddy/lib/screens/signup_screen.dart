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
  bool isDark = AppState.isDark.value;
  static final LightColor = AppState.LightColor;
  static final DarkColor = AppState.DarkColor;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final ageController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String? nameValidate(String? value) => value == null || value.isEmpty ? 'Enter name' : null;

  String? emailValidate(String? value) {
    if (value == null || value.isEmpty) return 'Email Required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? passwordValidate(String? value) =>
      value != null && value.length >= 8 ? null : 'Minimum 8 characters';

  String? confirmPasswordValidate(String? value) =>
      value == passwordController.text ? null : 'Password not match';

  String? phoneValidate(String? value) =>
      value != null && value.length == 11 ? null : 'Enter valid phone';

  String? ageValidate(String? value) =>
      value != null && int.tryParse(value) != null ? null : 'Enter valid age';


  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        setState(() => _isLoading = false);

        Flushbar(
          title: 'Success',
          message: 'Signup completed for ${nameController.text}',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(Icons.check_circle, color: Colors.white),
        ).show(context);

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        setState(() => _isLoading = false);

        Flushbar(
          title: 'Error',
          message: e.toString(),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(Icons.error, color: Colors.white),
        ).show(context);
      }
    }
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    ageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ?DarkColor : LightColor,
      appBar: AppBar(
        title: Text('Sign Buddy - Signup',style: TextStyle(color: isDark ? LightColor:DarkColor),),
        backgroundColor: isDark ? DarkColor: LightColor,
        iconTheme: IconThemeData(color: isDark ? LightColor:DarkColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? LightColor:DarkColor),
                ),
                SizedBox(height: 32),


                TextFormField(
                  controller: nameController,
                  validator: nameValidate,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person,color: isDark?LightColor:DarkColor,),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 16),


                TextFormField(
                  controller: emailController,
                  validator: emailValidate,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email,color : isDark?LightColor:DarkColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 16),


                TextFormField(
                  controller: passwordController,
                  validator: passwordValidate,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock,color : isDark?LightColor:DarkColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),


                TextFormField(
                  controller: confirmPasswordController,
                  validator: confirmPasswordValidate,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline,color : isDark?LightColor:DarkColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: phoneController,
                  validator: phoneValidate,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.call,color : isDark?LightColor:DarkColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 16),


                TextFormField(
                  controller: ageController,
                  validator: ageValidate,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake,color : isDark?LightColor:DarkColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isDark ? LightColor:DarkColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: isDark ?DarkColor: LightColor)
                      : Text('Signup', style: TextStyle(fontSize: 18, color: isDark ?DarkColor: LightColor)),
                ),

                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: TextStyle(color: isDark ? LightColor:DarkColor),),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text('Login', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? LightColor:DarkColor )),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
