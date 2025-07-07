import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Reusable button style
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      elevation: 5,
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorations
          Positioned(
            top: 40,
            left: -30,
            child: Icon(Icons.circle_outlined, color: Colors.purple[100], size: 100),
          ),
          Positioned(
            bottom: 40,
            right: -30,
            child: Icon(Icons.circle_outlined, color: Colors.purple[100], size: 100),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome heading
                Text(
                  "Welcome!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Sign up or log in to continue",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 30),
                // Center image
                Image.asset(
                  'lib/assets/signup.png', // Replace with your asset path
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
                SizedBox(height: 30),
                // Sign Up button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  icon: Icon(Icons.person_add, size: 20),
                  label: Text('Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: buttonStyle,
                ),
                SizedBox(height: 20),
                // Log In button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  icon: Icon(Icons.login, size: 20),
                  label: Text('Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: buttonStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
