import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Buddy',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade200, Colors.deepPurple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            //First Child of Column
            Lottie.asset(
              'assets/animations/Handshake Loop.json',
              width: 200, height: 200,
              fit: BoxFit.cover,
              repeat: true,
            ),

            SizedBox(height: 20),

            Text(
              'Welcome to Sign Buddy',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white,),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              'Sign to Text & Speech Translator',
              style: TextStyle(fontSize: 16, color: Colors.white70,),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 50),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.deepPurple[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.camera_alt, size: 28, color: Colors.white),
                  SizedBox(width: 15,),
                  Text('Start Translation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            ElevatedButton(

              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },

              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 60),
                backgroundColor: Colors.deepPurple[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.history, size: 28, color: Colors.white),
                  SizedBox(width: 15,),
                  Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,),
                  ),


                ],
              ),

            ),
          ],
        ),
      ),
    );
  }
}
