import 'dart:math'; // Needed for transaction reference generation
import 'dart:io'; // Potentially needed for platform checks, though not used in this direct conversion
import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart'; // Import the new package

class UpiPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String eventTitle; // New parameter to accept the event title

  const UpiPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.eventTitle, // Accept event title
  });

  @override
  _UpiPaymentScreenState createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  // Use UpiPay plugin instance
  final _upiPayPlugin = UpiPay();
  // Store the list of ApplicationMeta objects
  List<ApplicationMeta>? _apps;
  // Future for the transaction result
  Future<UpiTransactionResponse>? _transactionFuture;
  // Hardcoded UPI ID and Name (Replace with your actual details or fetch dynamically)
  final String _receiverUpiId = "6363299144@axl"; // <-- TODO: Replace with your UPI ID
  final String _receiverName = "Vaishnavi R Ram "; // <-- TODO: Replace with your Receiver Name

  @override
  void initState() {
    super.initState();
    // Fetch installed UPI apps using upi_pay
    _upiPayPlugin
        .getInstalledUpiApplications(
      statusType: UpiApplicationDiscoveryAppStatusType.all,
    )
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

  // Updated function to initiate transaction using upi_pay
  Future<UpiTransactionResponse> initiateTransaction(ApplicationMeta appMeta) async {
    // Generate a unique transaction reference
    final String transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");
    // Ensure amount is formatted correctly as a string
    final String amountString = widget.totalAmount.toStringAsFixed(2);

    // Initiate transaction using the upi_pay plugin
    return _upiPayPlugin.initiateTransaction(
      amount: amountString,
      app: appMeta.upiApplication, // Use the UpiApplication enum
      receiverName: _receiverName,
      receiverUpiAddress: _receiverUpiId,
      transactionRef: transactionRef,
      transactionNote: 'SafePay', // merchantCode: 'YOUR_MERCHANT_CODE', // Optional: Add if you have one
    );
  }

  // Updated widget to display apps fetched by upi_pay
  Widget displayUpiApps() {
    if (_apps == null) {
      // Show loading indicator while fetching apps
      return const Center(child: CircularProgressIndicator());
    } else if (_apps!.isEmpty) {
      // Show message if no apps are found
      return const Center(
        child: Text(
          "No UPI apps found on this device.",
          style: TextStyle(fontSize: 16, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // Sort apps alphabetically for consistent display
      _apps!.sort((a, b) => a.upiApplication
          .getAppName()
          .toLowerCase()
          .compareTo(b.upiApplication.getAppName().toLowerCase()));

      // Display apps in a Wrap layout
      return Wrap(
        spacing: 15, // Spacing between icons horizontally
        runSpacing: 15, // Spacing between rows vertically
        alignment: WrapAlignment.center, // Center the icons
        children: _apps!.map((appMeta) {
          return GestureDetector(
            onTap: () {
              // Initiate transaction when an app icon is tapped
              _transactionFuture = initiateTransaction(appMeta);
              setState(() {}); // Rebuild to show the FutureBuilder progress/result
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use iconImage method from ApplicationMeta
                appMeta.iconImage(60), // Request icon size
                const SizedBox(height: 6),
                // Use getAppName method from UpiApplication enum
                Text(
                  appMeta.upiApplication.getAppName(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis, // Handle long names
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
  }

  // Helper widget to display transaction details cleanly
  Widget displayTransactionData(String title, String? body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Flexible(
            child: Text(
              body ?? "N/A", // Display N/A if data is null
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Updated function to check transaction status using UpiTransactionStatus enum
  void _checkTxnStatus(UpiTransactionStatus? status, BuildContext context) {
    String message = "";
    bool isSuccess = false;
    switch (status) {
      case UpiTransactionStatus.success:
        message = "Payment Successful!";
        isSuccess = true;
        break;
      case UpiTransactionStatus.submitted:
      // Note: Some apps report SUBMITTED initially, then SUCCESS/FAILURE later.
      // You might want to implement polling or a webhook on your backend for definitive status.
        message = "Transaction Submitted! (Pending Confirmation)";
        break;
      case UpiTransactionStatus.failure:
        message = "Payment Failed.";
        break;
      default:
        message = "Transaction status unknown or cancelled.";
        break;
    }
    // Use ScaffoldMessenger safely after the build context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : (status == UpiTransactionStatus.failure ? Colors.red : Colors.orange),
        ),
      );
    });
  }

  // Helper to convert status enum to a readable string for display
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay via UPI"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
          children: [
            // Display event title
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Event: ${widget.eventTitle}", // Display event title
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Display amount clearly
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Amount Payable: ₹${widget.totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 25),
            // Display UPI app icons
            Text(
              "Select an app to pay:",
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
                  // Check connection state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    // Check if future completed with an error
                    if (snapshot.hasError) {
                      print("UPI Error: ${snapshot.error}"); // Log the actual error
                      return Center(
                        child: Text(
                          'Error Initiating Transaction:\n${snapshot.error.toString()}', // Display error
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    // Check if future completed with data
                    if (snapshot.hasData) {
                      final UpiTransactionResponse res = snapshot.data!;
                      // Check the transaction status using the helper function
                      _checkTxnStatus(res.status, context);
                      // Display transaction details
                      return Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // Make column size to content
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
                              displayTransactionData("Transaction Ref", res.txnRef), // Display original ref if needed
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
}