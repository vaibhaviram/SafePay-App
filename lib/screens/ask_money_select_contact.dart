import 'package:flutter/material.dart';

class AskMoneySelectContact extends StatelessWidget {
  const AskMoneySelectContact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text(
          'This is the Profile Page',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}