import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_buddy/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? profileImage;
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final uid = user.uid;
    final imagePath = prefs.getString('profileImage_$uid');

    if (imagePath != null) {
      profileImage = File(imagePath);
    }

    nameController.text = user.displayName ?? '';
    setState(() {});
  }


  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      final uid = user.uid;

      await prefs.setString('profileImage_$uid', image.path);

      setState(() {
        profileImage = File(image.path);
      });
    }
  }


  Future<void> saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateDisplayName(nameController.text.trim());
      await user.reload();
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppState.isDark.value
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
        iconTheme: IconThemeData(
          color: AppState.isDark.value
              ? Color(0xFFF0E7D5)
              : Color(0xFF212842),
        ),
      ),

      backgroundColor: AppState.isDark.value
          ? Color(0xFF212842)
          : Color(0xFFF0E7D5),

      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppState.isDark.value
                    ? Color(0xFFF0E7D5)
                    : Color(0xFF212842),
                backgroundImage:
                profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? Icon(
                  Icons.person,
                  size: 50,
                  color: AppState.isDark.value
                      ? Color(0xFF212842)
                      : Color(0xFFF0E7D5),
                )
                    : null,
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: nameController,
              style: TextStyle(
                color: AppState.isDark.value
                    ? Color(0xFFF0E7D5)
                    : Color(0xFF212842),
              ),
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
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

            SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: AppState.isDark.value
                    ? Color(0xFFF0E7D5)
                    : Color(0xFF212842),
              ),
              onPressed: saveProfile,
              child: Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 18,
                  color: AppState.isDark.value
                      ? Color(0xFF212842)
                      : Color(0xFFF0E7D5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
