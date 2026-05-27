import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_buddy/app_state.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? profileImage;
  var lightColor = AppState.lightColor;
  var darkColor = AppState.darkColor;

  int _currentIndex = 0; // 0=Home, 1=History, 2=Account

  @override
  void initState() {
    super.initState();
    loadTheme();
    loadProfileImage();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    AppState.isDark.value = prefs.getBool('isDark') ?? false;
    setState(() {});
  }

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final path = prefs.getString('profileImage_${user.uid}');
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await prefs.setString('profileImage_${user.uid}', image.path);
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

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 1) {
      // History
      Navigator.pushNamed(context, '/history');
      setState(() => _currentIndex = 0); // reset after navigation
    } else if (index == 2) {
      // Account  navigate to edit profile
      Navigator.pushNamed(context, '/edit').then((result) {
        if (result == true) loadProfileImage();
        setState(() => _currentIndex = 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = AppState.isDark.value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? darkColor : lightColor,
        foregroundColor: isDark ? lightColor : darkColor,
        title: Text(
          'Sign Buddy',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? lightColor : darkColor,
          ),
        ),
      ),

      backgroundColor: isDark ? darkColor : lightColor,

      // Bottom navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        backgroundColor: isDark ? darkColor : lightColor,
        selectedItemColor: isDark ? lightColor : darkColor,
        unselectedItemColor: (isDark ? lightColor : darkColor).withOpacity(0.4),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: isDark ? darkColor : lightColor,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? darkColor : lightColor,
              ),
              accountName: Text(
                user?.displayName ?? 'User',
                style: TextStyle(color: isDark ? lightColor : darkColor),
              ),
              accountEmail: Text(
                user?.email ?? '',
                style: TextStyle(color: isDark ? lightColor : darkColor),
              ),
              currentAccountPicture: GestureDetector(
                onTap: pickProfileImage,
                child: CircleAvatar(
                  backgroundColor: isDark ? lightColor : darkColor,
                  backgroundImage:
                  profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? Icon(Icons.person, size: 40,
                      color: isDark ? darkColor : lightColor)
                      : null,
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.person, color: isDark ? lightColor : darkColor),
              title: Text('Edit Profile',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              onTap: () async {
                final result = await Navigator.pushNamed(context, '/edit');
                if (result == true) loadProfileImage();
              },
            ),

            ListTile(
              leading: Icon(Icons.lock, color: isDark ? lightColor : darkColor),
              title: Text('Change Password',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              onTap: () => Navigator.pushNamed(context, '/forget'),
            ),

            ListTile(
              leading: Icon(Icons.menu_book, color: isDark ? lightColor : darkColor),
              title: Text('Learn Sign Language',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              onTap: openLearnASL,
            ),

            ListTile(
              leading: Icon(Icons.history, color: isDark ? lightColor : darkColor),
              title: Text('History',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),

            ListTile(
              leading: Icon(Icons.help, color: isDark ? lightColor : darkColor),
              title: Text('Help & Support',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Help'),
                    content: const Text('Email us at saudmasood010@gmail.com'),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.info, color: isDark ? lightColor : darkColor),
              title: Text('About App',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => const AlertDialog(
                    title: Text('Sign Buddy'),
                    content: Text(
                      'Sign Buddy is a Sign Language Recognition application that translates hand gestures into text and speech in real time. The app uses Artificial Intelligence and hand tracking technology to recognize sign language through the device camera. It provides an accessible and user-friendly platform to improve communication and includes features such as translation history, secure login, and sign language learning support.',
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: Icon(Icons.brightness_6,
                  color: isDark ? lightColor : darkColor),
              title: Text('Dark / Light Theme',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              trailing: Switch(
                value: AppState.isDark.value,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDark', val);
                  setState(() {
                    AppState.isDark.value = val;
                  });
                },
              ),
            ),

            ListTile(
              leading: Icon(Icons.logout, color: isDark ? lightColor : darkColor),
              title: Text('Sign Out',
                  style: TextStyle(color: isDark ? lightColor : darkColor)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/welcome');
              },
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: isDark ? darkColor : lightColor,
          child: Column(
            children: [

              Lottie.asset(
                'assets/animations/Handshake Loop.json',
                width: 70,
                height: 70,
              ),

              const SizedBox(height: 20),

              Text(
                'Welcome to Sign Buddy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? lightColor : darkColor,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Sign to Text & Speech Translator',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? lightColor : darkColor,
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: isDark ? lightColor : darkColor,
                ),
                onPressed: () => Navigator.pushNamed(context, '/camera'),
                child: Text(
                  'Start Translation',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? darkColor : lightColor,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: isDark ? lightColor : darkColor,
                ),
                onPressed: () => Navigator.pushNamed(context, '/history'),
                child: Text(
                  'View History',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? darkColor : lightColor,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              InkWell(
                onTap: openLearnASL,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 170,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
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
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),

                        child: const Row(
                          children: [
                            Icon(Icons.school, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Learn ASL Signs\nTap to explore alphabets & words',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
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