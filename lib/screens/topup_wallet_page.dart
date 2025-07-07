import 'dart:math';
import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TopUpWalletPage extends StatefulWidget {
  final double currentBalance;
  final Function(double) updateBalance; // Callback function to update balance

  TopUpWalletPage({required this.currentBalance, required this.updateBalance});

  @override
  _TopUpWalletPageState createState() => _TopUpWalletPageState();
}

class _TopUpWalletPageState extends State<TopUpWalletPage> {
  final _upiPayPlugin = UpiPay();
  List<ApplicationMeta>? _apps;
  Future<UpiTransactionResponse>? _transactionFuture;
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  final String _receiverUpiId = "6363299144@axl"; // Replace with your UPI ID
  final String _receiverName = "Vaishnavi R Ram"; // Replace with your Receiver Name

  @override
  void initState() {
    super.initState();
    _upiPayPlugin.getInstalledUpiApplications(statusType: UpiApplicationDiscoveryAppStatusType.all)
        .then((value) {
      setState(() {
        _apps = value;
      });
    }).catchError((e) {
      print("Error fetching UPI apps: $e");
      setState(() {
        _apps = [];
      });
    });
  }

  Future<UpiTransactionResponse> initiateTransaction(ApplicationMeta appMeta) async {
    final String transactionRef = Random.secure().nextInt(1 << 32).toString();
    final String amountString = _amountController.text.trim();
    return _upiPayPlugin.initiateTransaction(
      amount: amountString,
      app: appMeta.upiApplication,
      receiverName: _receiverName,
      receiverUpiAddress: _receiverUpiId,
      transactionRef: transactionRef,
      transactionNote: 'Top-up wallet',
    );
  }

  Widget displayUpiApps() {
    if (_apps == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (_apps!.isEmpty) {
      return const Center(
        child: Text(
          "No UPI apps found on this device.",
          style: TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      _apps!.sort((a, b) => a.upiApplication.getAppName().toLowerCase().compareTo(b.upiApplication.getAppName().toLowerCase()));
      return Wrap(
        spacing: 15,
        runSpacing: 15,
        alignment: WrapAlignment.center,
        children: _apps!.map((appMeta) {
          return GestureDetector(
            onTap: () {
              _transactionFuture = initiateTransaction(appMeta);
              setState(() {});
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                appMeta.iconImage(60),
                const SizedBox(height: 6),
                Text(
                  appMeta.upiApplication.getAppName(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  Widget displayTransactionData(String title, String? body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Flexible(
            child: Text(
              body ?? "N/A",
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _checkTxnStatus(UpiTransactionStatus? status, BuildContext context) {
    String message = "";
    bool isSuccess = false;
    switch (status) {
      case UpiTransactionStatus.success:
        message = "Payment Successful!";
        isSuccess = true;
        break;
      case UpiTransactionStatus.submitted:
        message = "Transaction Submitted! (Pending Confirmation)";
        break;
      case UpiTransactionStatus.failure:
        message = "Payment Failed.";
        break;
      default:
        message = "Transaction status unknown or cancelled.";
        break;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : (status == UpiTransactionStatus.failure ? Colors.red : Colors.orange),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Up Wallet via UPI"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display current wallet balance
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Current Balance: ₹${widget.currentBalance.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Amount input field
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: "Amount to Top Up"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            // Display UPI apps
            Text(
              "Select a UPI app to pay:",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            displayUpiApps(),
            const SizedBox(height: 25),
            const Divider(thickness: 1),
            const SizedBox(height: 15),
            // Display transaction results using FutureBuilder
            Expanded(
              child: FutureBuilder<UpiTransactionResponse>(
                future: _transactionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error initiating transaction:\n${snapshot.error.toString()}',
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      final UpiTransactionResponse res = snapshot.data!;
                      _checkTxnStatus(res.status, context);
                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                child: Text("Transaction Details:", style: Theme.of(context).textTheme.titleMedium),
                              ),
                              const Divider(),
                              displayTransactionData("Transaction ID", res.txnId),
                              displayTransactionData("Status", _getStatusString(res.status)),
                              displayTransactionData("Approval Ref No", res.approvalRefNo),
                              displayTransactionData("Response Code", res.responseCode),
                              displayTransactionData("Transaction Ref", res.txnRef),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text("No transaction data received."));
                    }
                  } else {
                    return const Center(child: Text("Select a UPI app above to initiate payment."));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusString(UpiTransactionStatus? status) {
    switch (status) {
      case UpiTransactionStatus.success:
        return "Success";
      case UpiTransactionStatus.submitted:
        return "Submitted (Pending)";
      case UpiTransactionStatus.failure:
        return "Failure";
      default:
        return "N/A";
    }
  }
}
