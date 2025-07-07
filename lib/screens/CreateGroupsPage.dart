import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateGroupsPage extends StatefulWidget {
  @override
  _CreateGroupsPageState createState() => _CreateGroupsPageState();
}

class _CreateGroupsPageState extends State<CreateGroupsPage> {
  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? "";
  }

  void _editGroup(String groupId, String currentName) {
    TextEditingController _controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Group Name"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "New Group Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('groups')
                    .doc(groupId)
                    .update({'groupName': _controller.text});
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteGroup(String groupId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Group"),
          content: Text("Are you sure you want to delete this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Groups"), backgroundColor: Colors.deepPurple),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .where('members', arrayContains: getCurrentUserId())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var groups = snapshot.data!.docs;
          if (groups.isEmpty) {
            return Center(child: Text("You are not in any groups"));
          }
          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              var group = groups[index];
              return ListTile(
                title: Text(group['groupName']),
                subtitle: Text("Members: ${group['members'].length}"),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editGroup(group.id, group['groupName']);
                    } else if (value == 'delete') {
                      _deleteGroup(group.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text("Edit")),
                    PopupMenuItem(value: 'delete', child: Text("Delete")),
                  ],
                ),
                onTap: () {
                  // Navigate to group details page
                },
              );
            },
          );
        },
      ),
    );
  }
}
