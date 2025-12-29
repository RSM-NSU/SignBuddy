import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDark = false;
  File? profileImage;

  @override
  void initState() {
    super.initState();
    loadTheme();
    loadProfileImage();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('isDark') ?? false;
    });
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profileImage');
    if (path != null) {
      setState(() {
        profileImage = File(path);
      });
    }
  }

  Future<void> pickProfileImage() async {
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

  void openLearnASL() async {
    final Uri url = Uri.parse('https://www.lifeprint.com/');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Buddy',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),

      backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple[400],

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'User'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: GestureDetector(
                onTap: pickProfileImage,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                  profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? Icon(Icons.person, size: 40, color: Colors.deepPurple)
                      : null,
                ),
              ),
              decoration: BoxDecoration(color: Colors.deepPurple),
            ),

            ListTile(
              leading: Icon(Icons.person),
              title: Text('Edit Profile'),
              onTap: () async {

                final result = await Navigator.pushNamed(context, '/edit');
                if (result == true) {
                  loadProfileImage();
                  setState(() {});
                }
              },
            ),

            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.pushNamed(context, '/forget');
              },
            ),

            ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('Learn Sign Language'),
              onTap: openLearnASL,
            ),

            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),

            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Help'),
                    content: Text('Email us at saudmasood010@gmail.com'),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.info),
              title: Text('About App'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Sign Buddy'),
                    content: Text(
                      'Sign Buddy converts sign language into text and speech.',
                    ),
                  ),
                );
              },
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.brightness_6),
              title: Text('Dark / Light Theme'),
              trailing: Switch(
                value: isDark,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDark', val);
                  setState(() {
                    isDark = val;
                  });
                },
              ),
            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          color: isDark ? Colors.grey[900] : Colors.deepPurple[400],
          child: Column(
            children: [

              Lottie.asset(
                'assets/animations/Handshake Loop.json',
                width: 70,
                height: 70,
              ),

              SizedBox(height: 20),

              Text(
                'Welcome to Sign Buddy',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),

              SizedBox(height: 10),

              Text(
                'Sign to Text & Speech Translator',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              SizedBox(height: 50),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor:
                  isDark ? Colors.deepPurple[700] : Colors.deepPurple[900],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: Text(
                  'Start Translation',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor:
                  isDark ? Colors.deepPurple[700] : Colors.deepPurple[900],
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: Text(
                  'View History',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),

              SizedBox(height: 30),

              InkWell(
                onTap: openLearnASL,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage('assets/images/asllearn.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.school, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Learn ASL Signs\nTap to explore alphabets & words',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
