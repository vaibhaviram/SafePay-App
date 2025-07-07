import 'package:flutter/material.dart';
import 'split_method_page.dart';

class SplitSelectionPage extends StatelessWidget {
  final List<String> participants;
  final double totalAmount;
  final Map<String, dynamic> eventData;

  SplitSelectionPage({
    required this.eventData,
    required this.participants,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Split Method")),

    body: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.blue.shade300, Colors.purple.shade300],
    ),
    ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose how you want to split the expense:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Equally Split
            Card(
              child: ListTile(
                title: Text("Equally", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Split amount equally among participants"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitMethodPage(
                        eventData: eventData,
                        method: "Equally",
                        participants: participants,
                        totalAmount: totalAmount,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Unequal Split
            Card(
              child: ListTile(
                title: Text("Unequally", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Manually enter each person's share"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitMethodPage(
                        eventData: eventData,
                        method: "Unequally",
                        participants: participants,
                        totalAmount: totalAmount,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Percentage Split
            Card(
              child: ListTile(
                title: Text("Percentages", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Split based on assigned percentages"),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitMethodPage(
                        eventData: eventData,
                        method: "Percentages",
                        participants: participants,
                        totalAmount: totalAmount,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
