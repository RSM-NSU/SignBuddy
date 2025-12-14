import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

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
  final notesController = TextEditingController();

  String? nameValidate(String? value) =>
      value == null || value.isEmpty ? 'Enter name' : null;

  String? emailValidate(String? value) =>
      value != null && value.contains('@') ? null : 'Enter valid email';

  String? passwordValidate(String? value) =>
      value != null && value.length >= 8 ? null : 'Min 8 characters';

  String? confirmPasswordValidate(String? value) =>
      value == passwordController.text ? null : 'Password not match';

  String? phoneValidate(String? value) =>
      value != null && value.length == 11 ? null : 'Enter valid phone';

  String? ageValidate(String? value) =>
      value != null && int.tryParse(value) != null ? null : 'Enter valid age';

  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    ageController.clear();
    notesController.clear();
  }

  void submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Flushbar(
          title: 'Success',
          message: 'Signup completed for ${nameController.text}',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          margin: EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
          icon: Icon(Icons.check_circle, color: Colors.white),
        ).show(context);

        Navigator.pushReplacementNamed(context, '/login'); // Go to login
      } catch (e) {
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

  void validateAndPreview() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Preview'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${nameController.text}'),
              Text('Email: ${emailController.text}'),
              Text('Phone: ${phoneController.text}'),
              Text('Age: ${ageController.text}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Buddy - Signup'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: nameValidate,
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@gmail.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: emailValidate,
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'At least 8 characters',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  validator: passwordValidate,
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                  validator: confirmPasswordValidate,
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    hintText: '03060000000',
                    prefixIcon: Icon(Icons.call),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: phoneValidate,
                ),
                SizedBox(height: 16),

                TextFormField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: '18',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: ageValidate,
                ),
                SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: submitForm,
                      child: Text('Signup'),
                    ),
                    ElevatedButton(
                      onPressed: validateAndPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('Preview'),
                    ),
                    TextButton(
                      onPressed: clearForm,
                      child: Text('Clear'),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                TextField(
                  controller: notesController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Any extra information',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
