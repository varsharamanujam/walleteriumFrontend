// lib/feature1/budget_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:walleterium/flutter_flow/flutter_flow_theme.dart';
import 'package:walleterium/flutter_flow/flutter_flow_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:uuid/uuid.dart';
import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

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

  List<DocumentSnapshot> _budgets = []; // List to hold fetched budget documents
  DocumentSnapshot? _selectedBudget; // Holds the budget currently being edited

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

  String get _passPayload {
    final String budgetName = _budgetNameController.text.trim();
    final String budgetAmount = _budgetAmountController.text.trim();

    final payloadMap = {
      "iss": _serviceAccountEmail,
      "aud": "google",
      "typ": "savetowallet",
      "origins": [],
      "payload": {
        "genericObjects": [
          {
            "id": "$_issuerId.$_passId",
            "classId": "$_issuerId.$_passClass",
            "genericType": "GENERIC_TYPE_UNSPECIFIED",
            "hexBackgroundColor": "#4285f4",
            "logo": {
              "sourceUri": {
                "uri": "https://storage.googleapis.com/wallet-lab-tools-codelab-artifacts-public/pass_google_logo.jpg"
              }
            },
            "cardTitle": {
              "defaultValue": {
                "language": "en",
                "value": "Budget: $budgetName"
              }
            },
            "subheader": {
              "defaultValue": {
                "language": "en",
                "value": "Amount Set"
              }
            },
            "header": {
              "defaultValue": {
                "language": "en",
                "value": "₹$budgetAmount"
              }
            },
            "barcode": {
              "type": "QR_CODE",
              "value": _passId
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

  // --- NEW: Function to fetch budgets from Firestore ---
  void _fetchBudgets() {
    final user = currentUser;
    if (user == null) {
      print('User not logged in, cannot fetch budgets.');
      return;
    }

    // Listen for real-time updates to the 'user_budgets' collection
    FirebaseFirestore.instance
        .collection('user_budgets')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _budgets = snapshot.docs;
          print('Budgets fetched: ${_budgets.length} items.');
        });
      }
    }, onError: (error) {
      print('Error fetching budgets: $error');
      _showSnackBar('Error loading your budgets.');
    });
  }

  // Function to handle saving/updating budget data and making the Wallet Pass button visible
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

    try {
      final budgetData = {
        'userId': user.uid,
        'budgetName': budgetName,
        'budgetAmount': budgetAmount,
        'createdAt': FieldValue.serverTimestamp(),
        'walletPassId': _passId, // Save the generated pass ID for future updates
      };

      if (_selectedBudget == null) {
        // Add new budget
        await FirebaseFirestore.instance.collection('user_budgets').add(budgetData);
        _showSnackBar('Budget "$budgetName" saved successfully to Firestore!');
        print('Budget "$budgetName" saved successfully to Firestore.');
      } else {
        // Update existing budget
        await _selectedBudget!.reference.update(budgetData);
        _showSnackBar('Budget "$budgetName" updated successfully in Firestore!');
        print('Budget "$budgetName" updated successfully in Firestore.');
        _clearForm(); // Clear form after update
      }

      // Make the Google Wallet Pass button visible
      setState(() {
        _showWalletButton = true;
      });
      _showSnackBar('Budget saved. Now tap "Add to Google Wallet" to save the pass.');
      print('BudgetGoalsScreen: Google Wallet button is now visible.');

    } catch (e) {
      _showSnackBar('Error saving budget: ${e.toString()}');
      print('Error saving budget to Firestore: $e');
    }
  }

  // --- NEW: Function to set form fields for editing ---
  void _editBudget(DocumentSnapshot budget) {
    setState(() {
      _selectedBudget = budget;
      _budgetNameController.text = budget['budgetName'];
      _budgetAmountController.text = budget['budgetAmount'].toString();
      // If you want to allow editing the passId, you'd update _passId here too,
      // but typically passId is immutable once created for a specific pass instance.
      // For simplicity, we'll keep _passId unique per form submission,
      // meaning editing won't change the Wallet Pass ID of an existing pass.
      // If you need to update an existing Wallet Pass, you'd use a backend function.
    });
    _showSnackBar('Editing budget: ${budget['budgetName']}');
  }

  // --- NEW: Function to delete a budget ---
  Future<void> _deleteBudget(String docId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (alertDialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this budget?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(alertDialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('user_budgets').doc(docId).delete();
      _showSnackBar('Budget deleted successfully!');
      print('Budget $docId deleted from Firestore.');
      _clearForm(); // Clear form if the deleted budget was being edited
    } catch (e) {
      _showSnackBar('Error deleting budget: ${e.toString()}');
      print('Error deleting budget: $e');
    }
  }

  // --- NEW: Function to clear the form and reset selected budget ---
  void _clearForm() {
    setState(() {
      _selectedBudget = null;
      _budgetNameController.clear();
      _budgetAmountController.clear();
      _passId = const Uuid().v4(); // Generate a new passId for a new budget
      _showWalletButton = false; // Hide wallet button for new entry
    });
    _showSnackBar('Form cleared. Ready to add a new budget.');
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
        actions: [
          // Add a clear form button to add new budget after editing
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add New Budget',
            onPressed: _clearForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedBudget == null ? 'Define Your Budget' : 'Edit Budget', // Dynamic title
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
            // Save/Update Budget Button
            FFButtonWidget(
              onPressed: _saveBudget, // Call the save/update function
              text: _selectedBudget == null ? 'Save Budget' : 'Update Budget', // Dynamic button text
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
            
            const SizedBox(height: 40), // Spacing before the list of budgets
            Text(
              'My Budgets',
              style: FlutterFlowTheme.of(context).headlineMedium,
            ),
            const SizedBox(height: 16),

            // --- List of Budgets (Table-like view) ---
            _budgets.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No budgets set yet. Add one above!'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true, // Important for nested ListView in SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling for nested list
                    itemCount: _budgets.length,
                    itemBuilder: (context, index) {
                      final budgetDoc = _budgets[index];
                      final budgetData = budgetDoc.data() as Map<String, dynamic>;
                      final budgetName = budgetData['budgetName'] ?? 'N/A';
                      final budgetAmount = budgetData['budgetAmount'] ?? 0.0;
                      final formattedAmount = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(budgetAmount);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      budgetName,
                                      style: FlutterFlowTheme.of(context).titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formattedAmount,
                                      style: FlutterFlowTheme.of(context).headlineSmall.override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context).primaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit Button
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editBudget(budgetDoc),
                                tooltip: 'Edit Budget',
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteBudget(budgetDoc.id),
                                tooltip: 'Delete Budget',
                              ),
                            ],
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
