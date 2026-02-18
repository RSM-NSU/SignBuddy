import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sign_buddy/app_state.dart';

class GuestHome extends StatefulWidget {
  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {

  void showLoginDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
        title: Text(
          "Login Required",
          style: TextStyle(
            color: AppState.isDark.value
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        content: Text(
          "Please login to access this feature",
          style: TextStyle(
            color: AppState.isDark.value
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: AppState.isDark.value
                    ? Color(0xFFF0E7D5)
                    : Color(0xFF212842),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    bool isDark = AppState.isDark.value;

    return Scaffold(

      appBar: AppBar(
        backgroundColor: isDark
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),
        title: Text(
          'Guest Mode',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark
                ? Color(0xFFF0E7D5)
                : Color(0xFF212842),
          ),
        ),

        actions: [

          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark
                  ? Color(0xFFF0E7D5)
                  : Color(0xFF212842),
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          ),

        ],
      ),

      backgroundColor: isDark
          ? Color(0xFF212842)
          : Color(0xFFF0E7D5),

      drawer: Drawer(
        backgroundColor: AppState.isDark.value
            ? Color(0xFF212842)
            : Color(0xFFF0E7D5),

        child: ListView(
          padding: EdgeInsets.zero,
          children: [

            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppState.isDark.value
                    ? Color(0xFF212842)
                    : Color(0xFFF0E7D5),
              ),
              accountName: Text(
                "Guest User",
                style: TextStyle(
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
              ),
              accountEmail: Text(""),
              currentAccountPicture: GestureDetector(
                onTap: showLoginDialog,
                child: CircleAvatar(
                  backgroundColor: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppState.isDark.value
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  ),
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.person,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842)),
              title: Text(
                'Profile',
                style: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842)),
              ),
              onTap: showLoginDialog,
            ),

            ListTile(
              leading: Icon(Icons.history,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842)),
              title: Text(
                'History',
                style: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842)),
              ),
              onTap: showLoginDialog,
            ),

            ListTile(
              leading: Icon(Icons.menu_book,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842)),
              title: Text(
                'Learn Sign Language',
                style: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842)),
              ),
              onTap: showLoginDialog,
            ),

            ListTile(
              leading: Icon(Icons.help,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842)),
              title: Text(
                'Help & Support',
                style: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842)),
              ),
              onTap: showLoginDialog,
            ),

            ListTile(
              leading: Icon(Icons.info,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842)),
              title: Text(
                'About App',
                style: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842)),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppState.isDark.value
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                    title: Text(
                      'Guest Mode',
                      style: TextStyle(
                        color: AppState.isDark.value
                            ? Color(0xFFF0E7D5)
                            : Color(0xFF212842),
                      ),
                    ),
                    content: Text(
                      'Sign Buddy converts sign language into text and speech.',
                      style: TextStyle(
                        color: AppState.isDark.value
                            ? Color(0xFFF0E7D5)
                            : Color(0xFF212842),
                      ),
                    ),
                  ),
                );
              },
            ),

            Divider(),

            ListTile(
              leading: Icon(Icons.brightness_6,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842)),
              title: Text(
                'Dark / Light Theme',
                style: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842)),
              ),
              trailing: Switch(
                value: AppState.isDark.value,
                onChanged: (val) {
                  setState(() {
                    AppState.isDark.value = val;
                  });
                },
              ),
            ),

            ListTile(
              leading: Icon(Icons.login,
                  color: AppState.isDark.value
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842)),
              title: Text(
                'Login',
                style: TextStyle(
                    color: AppState.isDark.value
                        ? Color(0xFFF0E7D5)
                        : Color(0xFF212842)),
              ),
              onTap: () {
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
                  color: isDark
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
              ),

              SizedBox(height: 10),

              Text(
                'Sign to Text & Speech Translator',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
              ),

              SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor: isDark
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: Text(
                  'Start Translation',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 60),
                  backgroundColor: isDark
                      ? Color(0xFFF0E7D5)
                      : Color(0xFF212842),
                ),
                onPressed: showLoginDialog,
                child: Text(
                  'View History',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark
                        ? Color(0xFF212842)
                        : Color(0xFFF0E7D5),
                  ),
                ),
              ),
              SizedBox(height: 30),

              InkWell(
                onTap: showLoginDialog,
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
