import 'package:flutter/material.dart';
import 'split_selection_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  EventDetailPage({required this.eventId,required this.eventData});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Map<String, TextEditingController> paymentControllers = {};
  Map<String, double> payments = {};
  Map<String, String> usernameMap = {}; // Store UID -> Username mapping

  @override
  void initState() {
    super.initState();
    _fetchUsernames();
  }

  Future<void> _fetchUsernames() async {
    List<String> participantUIDs = List<String>.from(widget.eventData['participants'] ?? []);

    // Fetch all usernames in a single batch
    List<DocumentSnapshot> userDocs = await Future.wait(
        participantUIDs.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get())
    );

    for (int i = 0; i < participantUIDs.length; i++) {
      if (userDocs[i].exists) {
        usernameMap[participantUIDs[i]] = userDocs[i]['username'] ?? participantUIDs[i];
      }
    }

    setState(() {
      for (String uid in participantUIDs) {
        paymentControllers[uid] = TextEditingController();
      }
    });
  }


  void _savePayments() async{
    payments.clear();
    paymentControllers.forEach((uid, controller) {
      double amount = double.tryParse(controller.text) ?? 0.0;
      if (amount > 0) {
        payments[usernameMap[uid] ?? uid] = amount;
      }
    });

    // Update eventData to pass payments
    widget.eventData['payments'] = payments;



    // Save to Firestore (ensure event ID is available)
    await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .update({'payments': payments});





    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var title = widget.eventData['title'] ?? "No Title";
    var description = widget.eventData['description'] ?? "No Description Available";
    var totalCost = double.tryParse(widget.eventData['totalCost'].toString()) ?? 0.0;
    List<String> participants = List<String>.from(widget.eventData['participants'] ?? []);

    return Scaffold(
      appBar: AppBar(title: Text("Event Details")),

    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.blue.shade300, Colors.purple.shade300],
    ),
    ),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
              SizedBox(height: 20),

              _buildHeading("Description:"),
              _buildDetailLine(description),
              SizedBox(height: 20),

              _buildHeading("Total Cost:"),
              _buildDetailLine("₹${totalCost.toStringAsFixed(2)}"),
              SizedBox(height: 20),

              _buildHeading("Participants:"),
              _buildDetailLine(participants.isEmpty
                  ? "No participants added yet."
                  : participants.map((uid) => usernameMap[uid] ?? uid).join(", ")),
              SizedBox(height: 20),

              _buildHeading("Enter Payments:"),
              ...participants.map((uid) => _buildPaymentField(uid, usernameMap[uid] ?? uid)),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _savePayments,
                child: Text("Save Payments"),
              ),

              if (payments.isNotEmpty) ...[
                SizedBox(height: 20),
                _buildHeading("Payments Made:"),
                ...payments.entries.map(
                      (entry) => _buildDetailLine("${entry.key}: ₹${entry.value.toStringAsFixed(2)}"),
                ),
              ],

              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitSelectionPage(
                        participants: participants.map((uid) => usernameMap[uid] ?? uid).toList(),
                        totalAmount: totalCost,
                        eventData: widget.eventData, // Pass updated eventData with

                      ),
                    ),
                  );
                },
                child: Text("Split Bill"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildDetailLine(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.black26)),
      child: Text(text, style: TextStyle(fontSize: 16, color: Colors.black)),
    );
  }

  Widget _buildPaymentField(String uid, String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Text(username, style: TextStyle(fontSize: 16))),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: paymentControllers[uid],
              keyboardType: TextInputType.number,
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: "Enter amount"),
            ),
          ),
        ],
      ),
    );
  }
}
