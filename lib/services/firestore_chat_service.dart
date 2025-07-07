import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Send a Message to Firestore
  Future<void> sendMessage(String chatRoomId, String receiverId, String messageText) async {
    if (messageText.trim().isEmpty) return; // Prevent empty messages
    try {
      String senderId = _auth.currentUser!.uid;

      // Generate a unique message ID in the chat room's messages collection
      DocumentReference messageRef = _firestore
          .collection("chatRooms")
          .doc(chatRoomId)
          .collection("messages")
          .doc(); // Firestore generates a unique document ID

      // Prepare the message to be added
      Map<String, dynamic> message = {
        "messageId": messageRef.id, // Store the message ID
        "senderId": senderId,
        "receiverId": receiverId,
        "text": messageText.trim(),
        "timestamp": FieldValue.serverTimestamp(), // Firestore will handle the timestamp
      };

      // Add the message to Firestore under the chat room's messages subcollection
      await messageRef.set(message);

      // Check if the chat room document exists in Firestore
      DocumentSnapshot chatRoomSnapshot = await _firestore.collection("chatRooms").doc(chatRoomId).get();

      if (!chatRoomSnapshot.exists) {
        // If the chat room doesn't exist, create it
        await _firestore.collection("chatRooms").doc(chatRoomId).set({
          "participants": FieldValue.arrayUnion([senderId, receiverId]), // Store both sender and receiver as participants
          "lastMessage": messageText.trim(),
          "lastMessageSender": senderId,
          "lastMessageTimestamp": FieldValue.serverTimestamp(),
        });
      } else {
        // If the chat room exists, just update the last message and other details
        await _firestore.collection("chatRooms").doc(chatRoomId).set({
          "lastMessage": messageText.trim(),
          "lastMessageSender": senderId,
          "lastMessageTimestamp": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Merge with existing data
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }


  /// Stream Messages from Firestore in Real-Time
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: true) // Oldest messages first
        .snapshots();
  }
}
