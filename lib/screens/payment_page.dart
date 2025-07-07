// payment_page.dart
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> eventData;

  PaymentPage({required this.eventData});

  @override
  Widget build(BuildContext context) {
    var eventTitle = eventData['title'];
    var totalCost = eventData['totalCost'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Page"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              eventTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Total Cost: \$${totalCost.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement payment logic here
                // After payment, navigate to the result page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentResultPage(),
                  ),
                );
              },
              child: Text("Proceed to Pay"),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Result"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          "Your payment has been successfully processed!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
