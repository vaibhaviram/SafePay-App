import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'wallet_setup_page.dart';
import 'topup_wallet_page.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isLoading = true;
  bool setupComplete = false;
  double walletBalance = 0.0;

  @override
  void initState() {
    super.initState();
    checkWalletSetup();
  }

  Future<void> checkWalletSetup() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null && data['wallet'] != null && data['wallet']['setupComplete'] == true) {
      setState(() {
        setupComplete = true;
        walletBalance = (data['wallet']['balance'] ?? 0.0).toDouble();
        isLoading = false;
      });
    } else {
      setState(() {
        setupComplete = false;
        isLoading = false;
      });
    }
  }

  // Function to update wallet balance after a top-up
  void updateBalance(double newBalance) {
    setState(() {
      walletBalance = newBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!setupComplete) {
      // Redirect to wallet setup page
      return WalletSetupPage(onSetupComplete: () {
        setState(() {
          setupComplete = true;
        });
        checkWalletSetup();
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text("My Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Wallet Balance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("₹${walletBalance.toStringAsFixed(2)}", style: TextStyle(fontSize: 32, color: Colors.green)),
            SizedBox(height: 30),
            Text("Top Up Wallet", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text("Proceed to Top Up"),
              onPressed: () {
                // Pass the current balance and the updateBalance function to the TopUpWalletPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TopUpWalletPage(
                      currentBalance: walletBalance,
                      updateBalance: updateBalance,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
