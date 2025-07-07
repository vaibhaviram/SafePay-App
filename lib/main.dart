import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_page.dart';
import 'screens/auth_page.dart';
import 'screens/signup.dart'; // From earlier
import 'screens/login.dart';// Create a login screen later




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafePay',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomePage(),
        '/auth': (context) => AuthPage(),
        '/signup': (context) => Signup(),
        '/login': (context) => Login(), // Add this later

      },
    );
  }
}
