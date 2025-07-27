// lib/feature1/budget_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:walleterium/flutter_flow/flutter_flow_theme.dart';
import 'package:walleterium/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:uuid/uuid.dart';
import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'dart:convert';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  static String routeName = '/edit_budget_goals';

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  // Controllers for the text input fields
  final TextEditingController _budgetNameController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();

  // --- GOOGLE WALLET SPECIFIC VARIABLES ---
  late String _passId; // Will be unique for each budget pass
  // IMPORTANT: Replace with your actual Issuer ID
  final String _issuerId = '3388000000022969114'; // <<< REPLACE WITH YOUR ISSUER ID
  // IMPORTANT: This MUST be the 'client_email' from your downloaded Service Account JSON key.
  final String _serviceAccountEmail = 'google-wallet-issuer-svc@walleterium.iam.gserviceaccount.com'; // <<< REPLACE WITH YOUR SERVICE ACCOUNT EMAIL
  // This is the Class ID you must create in Google Wallet Console (e.g., 'budget_pass')
  final String _passClass = 'budget'; // <<< You might need to create this class in the Wallet Console

  // Variable to hold the entire content of your Service Account JSON key file
  late String _serviceAccountKeyJson; // Will be loaded in initState

  // Control visibility of the wallet button after saving
  bool _showWalletButton = false; // <<< ADDED: State to control button visibility

  @override
  void initState() {
    super.initState();
    _passId = const Uuid().v4(); // Generate a unique ID for this pass instance
    _loadServiceAccountKey(); // Load the service account key when the screen initializes
  }

  // Function to load the service account key from a hardcoded string
  // For production, this key should be loaded securely from a backend or encrypted storage.
  Future<void> _loadServiceAccountKey() async {
    try {
      // IMPORTANT: Replace the entire placeholder string below with the EXACT content
      // of your downloaded Service Account JSON key file.
      const String keyJsonString = '''
      {
        "type": "service_account",
        "project_id": "walleterium",
        "private_key_id": "1870b6281d54c2525b973af78426e3526665dffb",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC4+cLh0uJILIuM\nnEQ3pJhkjQ/a2McHrfwoN9weILQsWHG3jBl8qtVo1cUVVIsZON0TsCwZvd/nUR2H\n27mzTQJqZPXkFXr51vJEkdpQZeGyUBReJLUraDty9VRdDFWBOvLzGJXP5neyRX4B\n0wC88PONtN8WjueuUxgfBABWK+sVxLM6NKycaUrABfph1BN+dfJyqK759hrAtkgK\nElDSYqtedQVGfRYuLOsJH5+8Uq/ZgN09hTRocTfxnP12WjCyCuJ1S3RfhcyuHecW\nxEF+MOm+nFzoeQG84JTkgGM6j1fCMCNRsIsVPRvvJKpmkna+3X+cw1avb9mD/FMe\nLeqmp+s7AgMBAAECggEARjHRuKy0Xjs5QcTTRmJZyl6Vk7EL5mgp9oEsMOqsNN/j\nV4n86ghSMBRfU/bfSlT/4EbMlYAuhbOMh0/kqpwgvItPnJxiLIlbKpZGyJfBDE/D\nSu6XKb/GP5vFxgG2OPJL2+CKiXimF6qzZLHT599wLWhj+EWGueqijrKQBiNodLuo\nz8EQ0a9qG24Q9eg8NcTS2htnuPscq+UME8l6jN2mQqz2U9ZCzKoI5PS6ncm3/aHV\nCDoAoCYeFF5URelO/xE+UvDqp3nYsDTxA5MVBeXDoTntKWePS6ZJbwKpk/02avxa\nEA49uNJzGbldStSxfHa44nChbva7/gaZzHrYZZEXYQKBgQDpX8Yn2rZoemYrKRc/\nuMEpKHC3Norn/0zW0fsd8AXNxGCOQ2Aq3/Fh9vZK0ZydL2rz9oatANStbct9wHkh\nX8cT8K7T7GnR1nc6dAiw9nLKi9Iqr/ZsphmrFJaXcZ1Ca5FYf4vhY30l/fccIPpk\nGNKZs5BMefKwTu7QBIg/LdKPYwKBgQDK6ML19QUXEa5sGGIOxlVw9j3Ls/2OIY5q\nucCgceoKQHj15wv4Lv5QZ7mheYpuPgamPso6olFv6VQzD/judeYJ+LXEiOKfZOcU\nJF5Mj/LkL4qpGObK/nfOhV3W1V9AlvetJpaSxR7Y5FjxWvaqxmc829Khy6tzj1Im\nscIcslFYSQKBgQCP+8kT+bqkxy+V3Wo8pE54iDzSrNISxM6xkyftlpLeGxS/cQ46\nJaSVnnriOmT4DbNdBXKd9m9A+QaddUzGrIL06H/UvH2lOz6gT8q087hrAs0ODTZq\nXihkBvXKRgySWC96fGbfDjS+Zew57JbPfwkgT0ruBCcZY/mvWbx9zlWkpQKBgQCr\naZ7psSevqVw0LRUJbjtXxm3F3DPjEi4BsxIreJBCQNzuv1S5QNnOixGie86Z+wQb\nBQhKKD2r0O00hdXBfQ/sdJL5iLoJ9W/Q8DhJbYG/ivoUh9jQu8/yQ3BWwMJLCj4J\npIOnUacRizYoDrQ66IjmPL3fuPMKGJVJ4vkczPczIQKBgH6oq+63+DdewVB0qjeu\nWCoUend/CUf2vwdWVWfNhj5/EBAn49xZa+r5JOjsrLGFr56hEUlYWz1nHgC6QlVb\nu3AGhYCwYud7h06ckNd71RD1aXBEcGG8hpMO0n74lj7TYezSbQeEwyLY+w2T4VQM\nkqwCFQ38pgcapnjEwFnY9E77\n-----END PRIVATE KEY-----\n",
        "client_email": "google-wallet-issuer-svc@walleterium.iam.gserviceaccount.com",
        "client_id": "108691337161052026294",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",r
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/google-wallet-issuer-svc%40walleterium.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }
      '''; // <<< PASTE YOUR ENTIRE SERVICE ACCOUNT JSON HERE
      
      setState(() {
        _serviceAccountKeyJson = keyJsonString;
      });
      print('BudgetGoalsScreen: Google Wallet Service Account Key loaded successfully.');
    } catch (e) {
      print('BudgetGoalsScreen: Error loading service account key: $e');
      _showSnackBar('Error loading Wallet API key for pass creation.');
    }
  }

  // Getter to dynamically create the Google Wallet pass payload based on user input
  String get _passPayload {
    final String budgetName = _budgetNameController.text.trim();
    final String budgetAmount = _budgetAmountController.text.trim(); // Keep as string for display

    final payloadMap = {
      "iss": _serviceAccountEmail, // Issuer email (service account email)
      "aud": "google", // Audience is always "google" for Wallet API
      "typ": "savetowallet", // Type for saving a pass
      "origins": [], // Optional: list of authorized web origins
      "payload": {
        "genericObjects": [
          {
            "id": "$_issuerId.$_passId", // Unique ID for this specific pass instance
            "classId": "$_issuerId.$_passClass", // ID of the pass class (defines design/type)
            "genericType": "GENERIC_TYPE_UNSPECIFIED",
            "hexBackgroundColor": "#4285f4", // Google Blue
            "logo": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/pass_google_logo.jpg"
              }
            },
            "cardTitle": {
              "defaultValue": {
                "language": "en",
                "value": "Budget: $budgetName" // Dynamic budget name
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "en",
                "value": "Amount Set" // Subheader
              }
            },
            "header": {
              "defaultValue": {
                "language": "en",
                "value": "₹$budgetAmount" // Display the budget amount here
              }
            },
            "barcode": {
              "type": "QR_CODE",
              "value": _passId // Barcode value can be the pass ID
            },
            "heroImage": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/google-io-hero-demo-only.jpg"
              }
            },
            "textModulesData": [
              {
                "header": "Budget Name",
                "body": budgetName,
                "id": "budgetName"
              },
              {
                "header": "Budget Amount",
                "body": budgetAmount,
                "id": "budgetAmount"
              }
            ]
          }
        ]
      }
    };
    return jsonEncode(payloadMap);
  }

  @override
  void dispose() {
    _budgetNameController.dispose();
    _budgetAmountController.dispose();
    super.dispose();
  }

  // Function to handle saving the budget data and making the Wallet Pass button visible
  Future<void> _saveBudget() async {
    final String budgetName = _budgetNameController.text.trim();
    final double? budgetAmount = double.tryParse(_budgetAmountController.text.trim());

    if (budgetName.isEmpty || budgetAmount == null) {
      _showSnackBar('Please enter both a budget name and a valid amount.');
      return;
    }

    final user = currentUser;
    if (user == null) {
      _showSnackBar('You must be logged in to save a budget.');
      print('Error: User is not logged in. Cannot save budget.');
      return;
    }

    _showSnackBar('Saving budget...');
    print('Attempting to save budget to Firestore:');
    print('  Budget Name: $budgetName');
    print('  Budget Amount: $budgetAmount');
    print('  User ID: ${user.uid}');

    try {
      // 1. Save the budget data to Firestore
      await FirebaseFirestore.instance.collection('user_budgets').add({
        'userId': user.uid,
        'budgetName': budgetName,
        'budgetAmount': budgetAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'walletPassId': _passId, // IMPORTANT: Save the generated pass ID for future updates
      });

      _showSnackBar('Budget "$budgetName" saved successfully to Firestore!');
      print('Budget "$budgetName" saved successfully to Firestore.');

      // 2. Make the Google Wallet Pass button visible
      setState(() {
        _showWalletButton = true; // <<< Set to true to show the button
      });
      _showSnackBar('Budget saved. Now tap "Add to Google Wallet" to save the pass.');
      print('BudgetGoalsScreen: Google Wallet button is now visible.');

      // Optionally, clear the fields after successful save
      // _budgetNameController.clear();
      // _budgetAmountController.clear();

      // You might want to navigate back after saving
      // Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Error saving budget: ${e.toString()}');
      print('Error saving budget to Firestore: $e');
    }
  }

  // Helper function to show a SnackBar message
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Budget'),
        backgroundColor: FlutterFlowTheme.of(context).primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Define Your Budget',
              style: FlutterFlowTheme.of(context).headlineMedium,
            ),
            const SizedBox(height: 16),
            // Text field for Budget Name
            TextFormField(
              controller: _budgetNameController,
              decoration: InputDecoration(
                labelText: 'Budget Name (e.g., Monthly Spending)',
                hintText: 'Enter budget name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 16),
            // Text field for Budget Amount
            TextFormField(
              controller: _budgetAmountController,
              keyboardType: TextInputType.number, // Ensure numeric keyboard
              decoration: InputDecoration(
                labelText: 'Budget Amount (e.g., 50000)',
                hintText: 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
            const SizedBox(height: 32),
            // Save Budget Button
            FFButtonWidget(
              onPressed: _saveBudget, // Call the save function
              text: 'Save Budget',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Inter',
                      color: Colors.white,
                    ),
                elevation: 3,
                borderSide: BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20), // Spacing below the save button

            // --- Conditionally display the AddToGoogleWalletButton ---
            if (_showWalletButton) // Only show if _showWalletButton is true
              if (_serviceAccountKeyJson?.isNotEmpty ?? false) // Also check if key is loaded
                AddToGoogleWalletButton(
                  pass: _passPayload, // Pass the dynamically generated payload
                  // serviceAccountKey: _serviceAccountKeyJson, // Pass the loaded key
                  onSuccess: () {
                    _showSnackBar('Budget Pass added to Google Wallet successfully!');
                    print('BudgetGoalsScreen: Budget Pass added successfully.');
                  },
                  onCanceled: () {
                    _showSnackBar('Add to Google Wallet cancelled.');
                    print('BudgetGoalsScreen: Action cancelled.');
                  },
                  onError: (Object error) {
                    _showSnackBar('Error adding Budget Pass to Wallet: ${error.toString()}');
                    print('BudgetGoalsScreen: Error adding pass - ${error.toString()}');
                  },
                  locale: const Locale.fromSubtags(
                    languageCode: 'en',
                    countryCode: 'US',
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(), // Show loading if key not ready
                ),
          ],
        ),
      ),
    );
  }
}
