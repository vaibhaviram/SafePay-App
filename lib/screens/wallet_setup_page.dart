import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'topup_wallet_page.dart';

class WalletSetupPage extends StatefulWidget {
  final VoidCallback onSetupComplete;

  WalletSetupPage({required this.onSetupComplete});

  @override
  _WalletSetupPageState createState() => _WalletSetupPageState();
}

class _WalletSetupPageState extends State<WalletSetupPage> {
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _panNumberController = TextEditingController();
  bool _isSubmitting = false;

  bool get isFormValid {
    return _bankNameController.text.isNotEmpty &&
        _accountNumberController.text.isNotEmpty &&
        _panNumberController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Setup Your Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Enter Your Bank Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            TextField(
              controller: _bankNameController,
              decoration: InputDecoration(labelText: "Bank Name"),
            ),
            TextField(
              controller: _accountNumberController,
              decoration: InputDecoration(labelText: "Account Number"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _panNumberController,
              decoration: InputDecoration(labelText: "PAN Number"),
            ),

            SizedBox(height: 30),

            _isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: isFormValid ? _submitSetup : null, // Disable button if form is invalid
              child: Text("Save & Complete Setup"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitSetup() async {
    if (!isFormValid) return;

    setState(() {
      _isSubmitting = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'wallet': {
          'balance': 0.0,
          'setupComplete': true,
          'transactions': [],
        },
        'bankDetails': {
          'bankName': _bankNameController.text,
          'accountNumber': _accountNumberController.text,
          'panCard': _panNumberController.text,
        }
      }, SetOptions(merge: true));

      // Notify the parent widget that setup is complete
      widget.onSetupComplete();

      // Fetch current balance after setup
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      double currentBalance = data?['wallet']['balance'] ?? 0.0;

      // Navigate to the TopUpWallet page, passing current balance and updateBalance
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TopUpWalletPage(
            currentBalance: currentBalance,
            updateBalance: (newBalance) {
              setState(() {
                currentBalance = newBalance;
              });
            },
          ),
        ),
      );
    } catch (e) {
      print("Error saving wallet setup: $e");
    }

    setState(() {
      _isSubmitting = false;
    });
  }
}

