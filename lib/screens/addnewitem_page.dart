import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddNewItemPage extends StatefulWidget {
  @override
  _AddNewItemPageState createState() => _AddNewItemPageState();
}

class _AddNewItemPageState extends State<AddNewItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();

  List<String> participants = [];
  List<String> friends = []; // List of friend UIDs
  Map<String, String> friendUsernames = {}; // Mapping of UID to username
  String totalCost = '';
  String hostId = ''; // Logged-in user's UID
  String hostName = 'Unknown'; // Logged-in user's username

  @override
  void initState() {
    super.initState();
    _fetchHostDetails(); // Get host details first
  }

  // Fetch the logged-in user's username and UID
  void _fetchHostDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      hostId = user.uid;

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
            'users').doc(hostId).get();
        if (userDoc.exists) {
          setState(() {
            hostName = userDoc['username'] ?? 'Unknown'; // Fetch username
          });
        }
      } catch (e) {
        print("Error fetching host details: $e");
      }

      _fetchFriends(); // Fetch friends after getting host details
    }
  }

  // Fetch friends and their usernames from Firestore
  void _fetchFriends() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
          'users').doc(hostId).get();
      if (userDoc.exists) {
        List<dynamic> friendList = userDoc['friends'] ?? [];
        setState(() {
          friends = List<String>.from(friendList);
        });

        // Fetch usernames for each friend
        for (String friendUid in friends) {
          DocumentSnapshot friendDoc = await FirebaseFirestore.instance
              .collection('users').doc(friendUid).get();
          if (friendDoc.exists) {
            String username = friendDoc['username'] ?? 'Unknown';
            setState(() {
              friendUsernames[friendUid] = username;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching friends: $e");
    }
  }

  // Add/remove participant
  void _toggleParticipant(String friendUid) {
    setState(() {
      if (participants.contains(friendUid)) {
        participants.remove(friendUid);
      } else {
        participants.add(friendUid);
      }
    });
  }

  // Create event in Firestore
  void _createEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!participants.contains(hostId)) {
        participants.add(hostId);
      }

      try {
        // Generate a unique document ID
        DocumentReference eventRef = FirebaseFirestore.instance.collection('events').doc();
        String eventId = eventRef.id; // Get the generated eventId

        await eventRef.set({
          'eventId': eventId,  // Store the eventId inside Firestore
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'totalCost': totalCost,
          'participants': participants,
          'hostId': hostId,
          'hostName': hostName,
          'rules': _rulesController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        print("Event created with ID: $eventId");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event created successfully!')),
        );

        // Clear the form
        _titleController.clear();
        _descriptionController.clear();
        _costController.clear();
        _rulesController.clear();
        setState(() {
          participants.clear();
        });

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating event: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Host a New Event'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.purple.shade300],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: kToolbarHeight + 20),
                // Adjust space for app bar
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Event Title',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  value == null || value
                      .trim()
                      .isEmpty
                      ? 'Please enter an event title'
                      : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Event Description',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  value == null || value
                      .trim()
                      .isEmpty
                      ? 'Please enter a description'
                      : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _costController,
                  decoration: InputDecoration(
                    labelText: 'Total Cost',
                    prefixText: '₹',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value == null || value
                      .trim()
                      .isEmpty
                      ? 'Please enter the total cost'
                      : null,
                  onChanged: (value) => totalCost = value,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _rulesController,
                  decoration: InputDecoration(
                    labelText: 'Rules for the Event',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) =>
                  value == null || value
                      .trim()
                      .isEmpty
                      ? 'Please enter the event rules'
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  'Host: $hostName',
                  style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Select Participants:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                friends.isEmpty
                    ? Text('No friends available. Add friends first.',
                    style: TextStyle(color: Colors.white))
                    : Wrap(
                  spacing: 8.0,
                  children: friends.map((friendUid) {
                    String username = friendUsernames[friendUid] ?? 'Unknown';
                    bool isSelected = participants.contains(friendUid);
                    return ChoiceChip(
                      label: Text(username),
                      selected: isSelected,
                      onSelected: (_) => _toggleParticipant(friendUid),
                      selectedColor: Colors.blueAccent,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _createEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
