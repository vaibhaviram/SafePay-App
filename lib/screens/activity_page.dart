import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Feed'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities')
            .orderBy('timestamp', descending: true) // Ensure activities are ordered by time
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No activities found.'));
          }

          var activities = snapshot.data!.docs;

          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              var activity = activities[index];
              var message = activity['message'] ?? 'No message';
              var timestamp = (activity['timestamp'] as Timestamp).toDate();
              var type = activity['type'];

              // Activity icon selection based on type
              IconData activityIcon;
              Color activityColor;
              switch (type) {
                case 'event_created':
                  activityIcon = Icons.event;
                  activityColor = Colors.green;
                  break;
                case 'bill_issued':
                  activityIcon = Icons.attach_money;
                  activityColor = Colors.orange;
                  break;
                case 'member_joined':
                  activityIcon = Icons.group_add;
                  activityColor = Colors.blue;
                  break;
                default:
                  activityIcon = Icons.info;
                  activityColor = Colors.grey;
              }

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 5,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: activityColor,
                    child: Icon(
                      activityIcon,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(message),
                  subtitle: Text('Timestamp: ${timestamp.toLocal()}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
