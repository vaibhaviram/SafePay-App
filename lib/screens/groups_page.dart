import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'CreateGroupsPage.dart'; // Import your existing CreatedGroupsPage

class GroupPage extends StatefulWidget {
  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> selectedFriends = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// Get Logged-in User ID
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  /// Fetch all users from Firestore
  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(
          'users').get();
      if (!mounted) return;
      setState(() {
        users = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>?;
          return {
            'id': doc.id,
            'username': data?['username'] ?? 'Unknown User',
          };
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      print("Error fetching users: $e");
    }
  }

  /// Create Group and Save in Firestore
  Future<void> _createGroup() async {
    String groupName = _groupNameController.text.trim();
    String groupDescription = _groupDescriptionController.text.trim();
    String currentUserId = getCurrentUserId();

    if (groupName.isEmpty || groupDescription.isEmpty ||
        selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            "Enter group name, description & select at least one friend")),
      );
      return;
    }

    try {
      // Include the creator in the group members list
      List<String> memberIds = selectedFriends.map((friend) =>
          friend['id'].toString()).toList();
      memberIds.add(currentUserId); // Add current user to group

      await FirebaseFirestore.instance.collection('groups').add({
        'groupName': groupName,
        'groupDescription': groupDescription,
        'createdBy': currentUserId,
        'members': memberIds, // Store member IDs in Firestore
        'createdAt': Timestamp.now(),
      });

      // Clear input fields after successful group creation
      _groupNameController.clear();
      _groupDescriptionController.clear();
      setState(() {
        selectedFriends.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Group '$groupName' created successfully!")),
      );
    } catch (e) {
      print("Error creating group: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to create group. Try again!")),
      );
    }
  }

  /// Search & Select Friends
  void _toggleFriendSelection(Map<String, dynamic> friend) {
    setState(() {
      if (selectedFriends.any((f) => f['id'] == friend['id'])) {
        selectedFriends.removeWhere((f) => f['id'] == friend['id']);
      } else {
        selectedFriends.add(friend);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a Group"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [

              /// Group Name Field
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(
                  labelText: "Group Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              /// Group Description Field
              TextField(
                controller: _groupDescriptionController,
                decoration: InputDecoration(
                  labelText: "Group Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              /// Search Friends Field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search Friends",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: 10),

              /// Friend List
              Expanded(
                child: ListView.builder(
                  itemCount: users
                      .where((user) =>
                      user['username']
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .length,
                  itemBuilder: (context, index) {
                    var filteredUsers = users
                        .where((user) =>
                        user['username']
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                        .toList();
                    var user = filteredUsers[index];
                    bool isSelected =
                    selectedFriends.any((f) => f['id'] == user['id']);
                    return ListTile(
                      title: Text(user['username']),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : Icon(Icons.add_circle_outline, color: Colors.grey),
                      onTap: () => _toggleFriendSelection(user),
                    );
                  },
                ),
              ),

              /// Create Group Button
              ElevatedButton(
                onPressed: _createGroup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple[300],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text("Create Group"),
              ),
              SizedBox(height: 10),

              /// View Created Groups Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateGroupsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300],
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text("View Created Groups"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
