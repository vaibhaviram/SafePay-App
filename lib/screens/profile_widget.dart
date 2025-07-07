import 'package:flutter/material.dart';
import 'profile_page.dart';

class ProfileWidget extends StatelessWidget {
  final String username; // Add this to pass the logged-in user's name

  const ProfileWidget({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person, color: Colors.white),
      onPressed: () {
        // Navigate to ProfilePage with the username
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(username: username)),
        );
      },
    );
  }
}
