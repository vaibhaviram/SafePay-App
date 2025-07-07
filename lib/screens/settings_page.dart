import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_card_page.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController panController = TextEditingController();
  final TextEditingController panHolderController = TextEditingController();  // Added controller for PAN holder name

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        nameController.text = userDoc['name'] ?? '';
        descriptionController.text = userDoc['description'] ?? '';
        panController.text = userDoc['panCard'] ?? '';
        panHolderController.text = userDoc['panHolder'] ?? '';  // Load PAN holder name from Firestore
      });
    }
  }

  // Save user details to Firestore
  Future<void> _saveUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'panCard': panController.text.trim(),
      'panHolder': panHolderController.text.trim(),  // Save PAN holder name to Firestore
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context, {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim(),
      'panCard': panController.text.trim(),
      'panHolder': panHolderController.text.trim(),  // Return PAN holder name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            Text("Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: nameController, decoration: InputDecoration(hintText: "Enter your name")),
            SizedBox(height: 15),

            // Description Field
            Text("Description", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: descriptionController, decoration: InputDecoration(hintText: "Enter a description")),
            SizedBox(height: 15),

            // PAN Card Field
            Text("PAN Card Number", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: panController, decoration: InputDecoration(hintText: "Enter PAN Card Number")),
            SizedBox(height: 15),

            // PAN Holder Name Field
            Text("PAN Holder Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(controller: panHolderController, decoration: InputDecoration(hintText: "Enter PAN Holder Name")),
            SizedBox(height: 25),

            // Manage Cards Section
            Text("Cards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListTile(
              title: Text("Manage cards"),
              onTap: () {}, // Add function to manage cards
            ),
            ListTile(
              title: Text("Add a card"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardPage()),
                );
              },
            ),

            // Save Button
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _saveUserData,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
