import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String receiverId; // Receiver ID is required
   // Add the receiver name field


  ChatScreen({required this.chatRoomId, required this.receiverId,   // Accept the receiver name
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirestoreChatService _chatService = FirestoreChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<Map<String, dynamic>> friendDetails;

  @override
  void initState() {
    super.initState();
    friendDetails = _getFriendDetails(widget.receiverId);
  }

  Future<Map<String, dynamic>> _getFriendDetails(String receiverId) async {
    DocumentSnapshot friendDoc = await FirebaseFirestore.instance.collection('users').doc(receiverId).get();
    return friendDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>>(
          future: friendDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading...");
            }
            if (snapshot.hasError) {
              return Text("Error loading name");
            }
            Map<String, dynamic> friend = snapshot.data!;
            return Text(friend['username'] ?? "Friend");
          },
        ),
      ),
      body: Column(
        children: [
          // Messages Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getMessages(widget.chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['senderId'] == _auth.currentUser!.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(message['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    if (_messageController.text.trim().isNotEmpty) {
                      try {
                        await _chatService.sendMessage(
                          widget.chatRoomId,
                          widget.receiverId,
                          _messageController.text,
                        );
                        _messageController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Message sent!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error sending message: $e")),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
