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
  bool isDark = AppState.isDark.value;
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ?  Color(0xFFF0E7D5): Color(0xFF212842)),
        ),
        backgroundColor: isDark ? Color(0xFF212842) : Color(0xFFF0E7D5),
      ),

      backgroundColor: isDark ? Color(0xFF212842) : Color(0xFFF0E7D5),

      drawer: Drawer(
        backgroundColor: isDark ?  Color(0xFF212842): Color(0xFFF0E7D5),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'User',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              accountEmail: Text(user?.email ?? '', style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              currentAccountPicture: GestureDetector(
                onTap: pickProfileImage,
                child: CircleAvatar(
                  backgroundColor: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842),
                  backgroundImage:
                  profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? Icon(Icons.person, size: 40, color: isDark ?  Color(0xFF212842): Color(0xFFF0E7D5))
                      : null,
                ),
              ),
              decoration: BoxDecoration(color: isDark ? Color(0xFF212842) : Color(0xFFF0E7D5)),
            ),

            ListTile(
              leading: Icon(Icons.person,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842),),
              title: Text('Edit Profile',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              onTap: () async {

                final result = await Navigator.pushNamed(context, '/edit');
                if (result == true) {
                  loadProfileImage();
                  setState(() {});
                }
              },
            ),

            ListTile(
              leading: Icon(Icons.lock,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
              title: Text('Change Password',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              onTap: () {
                Navigator.pushNamed(context, '/forget');
              },
            ),

            ListTile(
              leading: Icon(Icons.menu_book,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
              title: Text('Learn Sign Language',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              onTap: openLearnASL,
            ),

            ListTile(
              leading: Icon(Icons.history,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
              title: Text('History',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              onTap: () {
                Navigator.pushNamed(context, '/history');
              },
            ),

            ListTile(
              leading: Icon(Icons.help,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
              title: Text('Help & Support',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Help',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
                    content: Text('Email us at saudmasood010@gmail.com',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.info,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
              title: Text('About App',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Sign Buddy',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
                    content: Text(
                      'Sign Buddy converts sign language into text and speech.',
                      style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
                    ),
                  ),
                );
              },
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.brightness_6,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
              title: Text('Dark / Light Theme',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
              trailing: Switch(
                activeColor: isDark ?  Color(0xFFF0E7D5): Color(0xFF212842),
                value: isDark,
                onChanged: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDark', val);
                  setState(() {
                    isDark = val;
                    AppState.isDark.value = val;
                  }
                  );

                },
              ),
            ),

            ListTile(
              leading: Icon(Icons.logout,color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),
              title: Text('Sign Out',style: TextStyle(color: isDark ? Color(0xFFF0E7D5) : Color(0xFF212842)),),
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
          color: isDark ? Color(0xFF212842) : Color(0xFFF0E7D5),
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
                    color:isDark ?  Color(0xFFF0E7D5): Color(0xFF212842)),
              ),

              SizedBox(height: 10),

              Text(
                'Sign to Text & Speech Translator',
                style: TextStyle(fontSize: 16, color:isDark ?  Color(0xFFF0E7D5): Color(0xFF212842)),
              ),

              SizedBox(height: 50),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor:
                  isDark ? Color(0xFFF0E7D5): Color(0xFF212842),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: Text(
                  'Start Translation',
                  style: TextStyle(fontSize: 20, color:isDark ?  Color(0xFF212842): Color(0xFFF0E7D5) ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor:
                  isDark ? Color(0xFFF0E7D5): Color(0xFF212842),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: Text(
                  'View History',
                  style: TextStyle(fontSize: 20, color:isDark ?  Color(0xFF212842): Color(0xFFF0E7D5)),
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
