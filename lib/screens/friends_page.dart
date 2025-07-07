import 'package:safety/screens/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendPage> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> friendsList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
    fetchFriends();
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");
    } else {
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1Uid, String user2Uid) {
    List<String> users = [user1Uid, user2Uid];
    users.sort(); // To ensure consistency
    return users.join("_");
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("username", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs.isNotEmpty ? value.docs[0].data() : null;
        isLoading = false;
      });
    });
  }

  Future<void> addFriend(String friendUid) async {
    try {
      String currentUserUid = _auth.currentUser!.uid;

      DocumentReference userDoc = _firestore.collection('users').doc(currentUserUid);
      await userDoc.update({'friends': FieldValue.arrayUnion([friendUid])});

      DocumentReference friendDoc = _firestore.collection('users').doc(friendUid);
      await friendDoc.update({'friends': FieldValue.arrayUnion([currentUserUid])});

      fetchFriends();
    } catch (e) {
      print("Error adding friend: $e");
    }
  }

  void fetchFriends() async {
    String currentUserUid = _auth.currentUser!.uid;
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUserUid).get();

      if (userDoc.exists) {
        List<dynamic> friends = userDoc['friends'] ?? [];
        List<Map<String, dynamic>> friendList = [];

        for (String friendUid in friends) {
          DocumentSnapshot friendDoc = await _firestore.collection('users').doc(friendUid).get();
          if (friendDoc.exists) {
            final friendData = friendDoc.data() as Map<String, dynamic>;
            friendData['uid'] = friendUid;
            friendList.add(friendData);
          }
        }

        setState(() {
          friendsList = friendList;
        });
      }
    } catch (e) {
      print("Error fetching friends: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text("Friends")),
      backgroundColor: Colors.blue.shade300,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            SizedBox(height: size.height / 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width / 15),
              child: TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: "Search for a friend",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height / 50),
            ElevatedButton(onPressed: onSearch, child: Text("Search")),
            SizedBox(height: size.height / 30),
            friendsList.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: friendsList.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> friend = friendsList[index];
                  return ListTile(
                    onTap: () {
                      String roomId = chatRoomId(
                        _auth.currentUser!.uid,
                        friend['uid'],
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatRoomId: roomId,
                            receiverId: friend['uid'],
                          ),
                        ),
                      );
                    },
                    leading: Icon(Icons.account_box, color: Colors.white),
                    title: Text(
                      friend['username'] ?? "Unknown User",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(friend['name'] ?? "No name available",
                        style: TextStyle(color: Colors.white70)),
                    trailing: Icon(Icons.chat, color: Colors.white),
                  );
                },
              ),
            )
                : Center(
                child: Text("No friends added yet",
                    style: TextStyle(color: Colors.white))),
            userMap != null
                ? ListTile(
              onTap: () async {
                String roomId = chatRoomId(
                  _auth.currentUser!.uid,
                  userMap!['uid'],
                );
                await addFriend(userMap!['uid']);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      chatRoomId: roomId,
                      receiverId: userMap!['uid'],
                    ),
                  ),
                );
              },
              leading: Icon(Icons.account_box, color: Colors.white),
              title: Text(userMap!['username'] ?? "Unknown User",
                  style: TextStyle(color: Colors.white)),
              subtitle: Text(userMap!['name'] ?? "No name available",
                  style: TextStyle(color: Colors.white70)),
              trailing: Icon(Icons.chat, color: Colors.white),
            )
                : Container(),
          ],
        ),
      ),
    );
  }
}
