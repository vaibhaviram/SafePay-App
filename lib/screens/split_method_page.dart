import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ExpenseChartPage.dart'; // Import the chart page
import 'package:fl_chart/fl_chart.dart'; // Import FL Chart for Pie Chart
import 'package:firebase_auth/firebase_auth.dart';
import 'SplitConfirmationPage.dart';



class SplitMethodPage extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String method;
  final double totalAmount;
  final List<String> participants;

  SplitMethodPage({
    required this.eventData,
    required this.method,
    required this.totalAmount,
    required this.participants,
  });


  @override
  _SplitMethodPageState createState() => _SplitMethodPageState();
}

class _SplitMethodPageState extends State<SplitMethodPage> {
  Map<String, double> userContributions = {};
  Map<String, double> userOwes = {};
  List<String> settlementResults = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, TextEditingController> controllers = {};


  @override
  void initState() {
    super.initState();

    // Step 1: Initialize contributions from eventData['payments']
    for (var participant in widget.participants) {
      userContributions[participant] =
          widget.eventData['payments']?[participant]?.toDouble() ?? 0.0;
    }

    @override
    void dispose() {
      for (var controller in controllers.values) {
        controller.dispose();
      }
      super.dispose();
    }



    _firestore.collection('split_bills').doc(widget.eventData['title']).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        setState(() {
          userContributions = Map<String, double>.from(
              snapshot.data()?['contributions']?.map((key, value) => MapEntry(key, value.toDouble())) ?? {});
          userOwes = Map<String, double>.from(
              snapshot.data()?['amountsOwed']?.map((key, value) => MapEntry(key, value.toDouble())) ?? {});
          settlementResults = List<String>.from(snapshot.data()?['settlements'] ?? []);
        });
      }
    });
  }



  void updateSplit() {
    setState(() {
      double totalPaid = userContributions.values.fold(0.0, (sum, value) => sum + value);
      userOwes.clear();
      if (widget.method == 'Equally') {
        double perPerson = widget.totalAmount / widget.participants.length;
        widget.participants.forEach((participant) {
          double alreadyPaid = userContributions[participant] ?? 0.0;
          userOwes[participant] = perPerson - alreadyPaid;
        });
      } else if (widget.method == 'Unequally') {
        double sumExpected = userContributions.values.fold(0.0, (sum, value) => sum + value);
        if (sumExpected != widget.totalAmount) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Total entered amount must equal the total expense")),
          );
          return;
        }
        widget.participants.forEach((participant) {
          double expectedToPay = userContributions[participant] ?? 0.0;
          double alreadyPaid = widget.eventData['payments']?[participant]?.toDouble() ?? 0.0;
          userOwes[participant] = expectedToPay - alreadyPaid;
        });
      } else if (widget.method == 'Percentages') {
        double totalPercentage = userContributions.values.fold(0.0, (sum, value) => sum + value);
        if (totalPercentage != 100.0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Total percentage should be exactly 100%")),
          );
          return;
        }
        widget.participants.forEach((participant) {
          double percentage = userContributions[participant] ?? 0.0;
          double expectedAmount = (percentage / 100) * widget.totalAmount;
          double alreadyPaid = widget.eventData['payments']?[participant]?.toDouble() ?? 0.0;
          userOwes[participant] = expectedAmount - alreadyPaid;
        });
      }
      calculateWhoOwesWhom();
      storeSplitData();
    });
  }

  void calculateWhoOwesWhom() {
    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];
    userOwes.forEach((user, amount) {
      if (amount > 0) {
        debtors.add(MapEntry(user, amount));
      } else if (amount < 0) {
        creditors.add(MapEntry(user, -amount));
      }
    });
    List<String> settlementStatements = [];
    int i = 0, j = 0;
    while (i < debtors.length && j < creditors.length) {
      String debtor = debtors[i].key;
      double debtAmount = debtors[i].value;
      String creditor = creditors[j].key;
      double creditAmount = creditors[j].value;
      double settledAmount = debtAmount < creditAmount ? debtAmount : creditAmount;
      settlementStatements.add("$debtor should pay ₹${settledAmount.toStringAsFixed(2)} to $creditor");
      debtors[i] = MapEntry(debtor, debtAmount - settledAmount);
      creditors[j] = MapEntry(creditor, creditAmount - settledAmount);
      if (debtors[i].value == 0) i++;
      if (creditors[j].value == 0) j++;
    }
    setState(() {
      settlementResults = settlementStatements;
    });
  }

  void storeSplitData() async {
    await _firestore.collection('split_bills').doc(widget.eventData['title']).set({
      'eventName': widget.eventData['title'],
      'method': widget.method,
      'totalAmount': widget.totalAmount,
      'participants': widget.participants,
      'contributions': userContributions,
      'amountsOwed': userOwes,
      'settlements': settlementResults,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));  // Merge ensures updates instead of overwriting
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.method} Split")),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.purple.shade300],
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.participants.length,
                itemBuilder: (context, index) {
                  String participant = widget.participants[index];
                  return ListTile(
                    title: Text(participant),
                    subtitle: Text("Owes: ₹${userOwes[participant]?.toStringAsFixed(2) ?? '0.00'}"),
                    trailing: SizedBox(
                      width: 80,
                      child: TextField(


                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: widget.method == 'Percentages' ? "Enter %" : "Amount"),
                        onChanged: (value) {
                          setState(() {
                            userContributions[participant] = double.tryParse(value) ?? 0.0;
                            storeSplitData();
                            bool userHasToPay() {
                              final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                              if (currentUserId == null) return false;
                              final amountOwed = userOwes[currentUserId] ?? 0.0;
                              return amountOwed > 0;
                            }

                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateSplit,
              child: Text("Apply Split"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: settlementResults.map((statement) {
                  return ListTile(
                    title: Text(statement),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExpenseChartPage(userContributions: userContributions),
                  ),
                );
              },
              child: Text("View Expense Chart"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
             onPressed: () {
              Navigator.push(

                context,
                MaterialPageRoute(
                  builder: (context) => SplitConfirmationPage(
                    totalAmount: widget.totalAmount,
                    eventTitle: widget.eventData['title'],  // Pass the event title here
                    settlementResults: settlementResults,  // Pass the settlement results for confirmation

                  ),

                ),
              );
              },
              child: Text("Settle Up"),
      ),
]


    ),
      ),
    );
  }
}
