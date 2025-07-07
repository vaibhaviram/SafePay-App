import 'package:flutter/material.dart';

class AddCardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add a Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add New Card",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(labelText: "Name on card"),
            ),

            TextField(
              decoration: InputDecoration(labelText: "Card number"),
              keyboardType: TextInputType.number,
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: "Expiry date"),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: "CVV"),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                // Add function to save the card
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              child: Center(
                child: Text("Add Card", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
