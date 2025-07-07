import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UpiPaymentScreen.dart';

class SplitConfirmationPage extends StatefulWidget {
  final double totalAmount;
  final String eventTitle;
  final List<String> settlementResults;

  const SplitConfirmationPage({
    required this.totalAmount,
    required this.eventTitle,
    required this.settlementResults,
  });

  @override
  _SplitConfirmationPageState createState() => _SplitConfirmationPageState();
}

class _SplitConfirmationPageState extends State<SplitConfirmationPage> {
  Map<String, double> userOwes = {};
  String? currentUsername;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsernameAndSplitData();
  }

  Future<void> fetchUsernameAndSplitData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final fetchedUsername = userDoc['username'] as String?;

      if (fetchedUsername == null) throw Exception("Username not found");

      final splitDoc = await FirebaseFirestore.instance
          .collection('split_bills')
          .doc(widget.eventTitle)
          .get();

      if (splitDoc.exists) {
        final rawData = splitDoc['amountsOwed'] ?? {};
        setState(() {
          currentUsername = fetchedUsername;
          userOwes = Map<String, double>.from(
            rawData.map((key, value) => MapEntry(key, (value as num).toDouble())),
          );
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  bool userHasToPay() {
    if (currentUsername == null) return false;
    final amountOwed = userOwes[currentUsername] ?? 0.0;
    return amountOwed > 0;
  }

  double getUserOwedAmount() {
    if (currentUsername == null) return 0.0;
    return userOwes[currentUsername] ?? 0.0;
  }

  Future<void> createNotification(String toUsername, double amount) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final fromUsername = currentUserDoc.data()?['username'] ?? 'Unknown';

      print("🟢 Sending notification from $fromUsername to $toUsername");

      await FirebaseFirestore.instance.collection('notifications').add({
        'toUserId': toUsername, // ✅ already a username
        'fromUserId': fromUsername, // ✅ store username for consistency
        'eventTitle': widget.eventTitle,
        'amount': amount,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'message': "You owe ₹$amount for the event '${widget.eventTitle}'",
      });

      print("✅ Notification sent to $toUsername");
    } catch (e) {
      print("❌ Error sending notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = [Colors.blue.shade300, Colors.purple.shade300];

    return Scaffold(
      appBar: AppBar(
        title: Text("Split Confirmation"),
        backgroundColor: Colors.blue.shade300,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "Settlement Summary",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.settlementResults.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      leading:
                      Icon(Icons.check_circle, color: Colors.green),
                      title: Text(widget.settlementResults[index]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            if (userHasToPay()) ...[
              Text(
                "You owe ₹${getUserOwedAmount().toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  padding:
                  EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  for (var username in userOwes.keys) {
                    if (userOwes[username]! > 0) {
                      await createNotification(
                          username, userOwes[username]!);
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpiPaymentScreen(
                        totalAmount: getUserOwedAmount(),
                        eventTitle: widget.eventTitle,
                      ),
                    ),
                  );
                },
                child: Text("Settle Up"),
              ),
            ] else ...[
              Text(
                "🎉 You're all settled!",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ],
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
