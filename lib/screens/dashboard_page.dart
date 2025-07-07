import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'event_detail_page.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _totalCostController = TextEditingController();
  User? _currentUser;
  String _currentUsername = "";

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() async {
    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(_currentUser!.uid).get();
      if (userDoc.exists) {
        setState(() {
          _currentUsername = userDoc['username'];
        });
      }
    }
  }

  void _editEvent(String eventId, Map<String, dynamic> eventData) {
    _titleController.text = eventData['title'] ?? '';
    _descriptionController.text = eventData['description'] ?? '';
    _totalCostController.text = eventData['totalCost']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Event"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                  value!.isEmpty ? 'Enter a description' : null,
                ),
                TextFormField(
                  controller: _totalCostController,
                  decoration: InputDecoration(labelText: 'Total Cost'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? 'Enter total cost' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _firestore.collection('events').doc(eventId).update({
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'totalCost': double.tryParse(_totalCostController.text) ??
                        0,
                  });
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext context, String eventId,
      Map<String, dynamic> eventData) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Edit Event'),
              onTap: () {
                Navigator.pop(context);
                _editEvent(eventId, eventData);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Event'),
              onTap: () {
                Navigator.pop(context);
                _deleteEvent(eventId);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteEvent(String eventId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Event?"),
          content: Text("Are you sure you want to delete this event?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('events').doc(eventId).delete();
                Navigator.pop(context);
              },
              child: Text("Delete"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.purple.shade300],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, $_currentUsername",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add Expense functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade300, // Green button
                          foregroundColor: Colors.white, // White text
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Add Expense"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Split Expense functionality here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade300, // Blue button
                          foregroundColor: Colors.white, // White text
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("Split Expense"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('events')
                    .where('participants', arrayContains: _currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No events available"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> eventData =
                      doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(eventData['title'] ?? 'No Title'),
                          subtitle: Text(
                              eventData['description'] ?? 'No Description'),
                          trailing: Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailPage(
                                        eventId: doc.id, eventData: eventData),
                              ),
                            );
                          },
                          onLongPress: () =>
                              _showOptionsMenu(context, doc.id, eventData),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
