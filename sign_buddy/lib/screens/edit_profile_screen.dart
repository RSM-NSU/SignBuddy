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
      backgroundColor: AppState.isDark.value
          ? Color(0xFF212842)
          : Color(0xFFF0E7D5),

      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppState.isDark.value ? Color(0xFFF0E7D5) : Color(0xFF212842),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppState.isDark.value ? Color(0xFFF0E7D5) : Color(0xFF212842),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(height: 20),

            // ── Profile Picture
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                  backgroundImage: profileImage != null
                      ? FileImage(profileImage!)
                      : null,
                  child: profileImage == null
                      ? Icon(
                    Icons.person,
                    size: 60,
                    color: AppState.isDark.value
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: AppState.isDark.value
                          ? Color(0xFFF0E7D5)
                          : Color(0xFF212842),
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: AppState.isDark.value
                            ? Color(0xFF212842)
                            : Color(0xFFF0E7D5),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            Text(
              'Tap camera to change photo',
              style: TextStyle(
                fontSize: 13,
                color: AppState.isDark.value
                    ? Color(0xFFF0E7D5).withOpacity(0.5)
                    : Color(0xFF212842).withOpacity(0.5),
              ),
            ),

            SizedBox(height: 40),

            // ── Name Field
            TextField(
              controller: nameController,
              style: TextStyle(
                color: AppState.isDark.value
                    ? Color(0xFFF0E7D5)
                    : Color(0xFF212842),
              ),
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
                labelStyle: TextStyle(
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
              ),
            ),

            SizedBox(height: 20),

            // Email Field
            TextField(
              readOnly: true,
              style: TextStyle(
                color: AppState.isDark.value
                    ? Color(0xFFF0E7D5).withOpacity(0.5)
                    : Color(0xFF212842).withOpacity(0.5),
              ),
              controller: TextEditingController(
                text: FirebaseAuth.instance.currentUser?.email ?? '',
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5).withOpacity(0.5)
                      : Color(0xFF212842).withOpacity(0.5),
                ),
                labelStyle: TextStyle(
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5).withOpacity(0.5)
                      : Color(0xFF212842).withOpacity(0.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5).withOpacity(0.3)
                        : Color(0xFF212842).withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5).withOpacity(0.3)
                        : Color(0xFF212842).withOpacity(0.3),
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),

            // ── Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 54),
                backgroundColor: AppState.isDark.value
                    ? Color(0xFFF0E7D5)
                    : Color(0xFF212842),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: saveProfile,
              child: Text(
                'Save Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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