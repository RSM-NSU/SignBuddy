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
  final bool isDark = AppState.isDark.value;
  final LightColor = AppState.LightColor;
  final DarkColor = AppState.DarkColor;

  File? profileImage;
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profileImage');
    final user = FirebaseAuth.instance.currentUser;

    if (imagePath != null) {
      profileImage = File(imagePath);
    }

    nameController.text = user?.displayName ?? '';
    setState(() {});
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', image.path);

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

    Navigator.pop(context, true); // VERY IMPORTANT
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',style: TextStyle(color: isDark ? LightColor:DarkColor),),
        backgroundColor: isDark ? DarkColor : LightColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                profileImage != null ? FileImage(profileImage!) : null,
                child: profileImage == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),

            SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: isDark ? DarkColor : LightColor),
              child: Text('Save Profile',style: TextStyle(color: isDark ? LightColor:DarkColor),),
            ),
          ],
        ),
      ),
    );
  }
}
