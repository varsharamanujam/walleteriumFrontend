// lib/feature1/budget_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:walleterium/flutter_flow/flutter_flow_theme.dart';
import 'package:walleterium/flutter_flow/flutter_flow_widgets.dart'; // Assuming FFButtonWidget is here
import 'package:cloud_firestore/cloud_firestore.dart'; // <<< ADDED: Import for Firestore
import '/auth/firebase_auth/auth_util.dart'; // <<< ADDED: Import for currentUser

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  static String routeName = '/edit_budget_goals'; // Keep the route name

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  // Controllers for the text input fields
  final TextEditingController _budgetNameController = TextEditingController();
  final TextEditingController _budgetAmountController = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed
    _budgetNameController.dispose();
    _budgetAmountController.dispose();
    super.dispose();
  }

  // Function to handle saving the budget data
  Future<void> _saveBudget() async { // <<< MADE ASYNC
    final String budgetName = _budgetNameController.text.trim();
    final double? budgetAmount = double.tryParse(_budgetAmountController.text.trim());

    if (budgetName.isEmpty || budgetAmount == null) {
      _showSnackBar('Please enter both a budget name and a valid amount.');
      return;
    }

    final user = currentUser; // Get the current user
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
      // Save the budget data to a 'user_budgets' collection in Firestore
      await FirebaseFirestore.instance.collection('user_budgets').add({
        'userId': user.uid, // Store the user's ID
        'budgetName': budgetName,
        'budgetAmount': budgetAmount,
        'createdAt': FieldValue.serverTimestamp(), // Timestamp of creation
      });

      _showSnackBar('Budget "$budgetName" saved successfully to Firestore!');
      print('Budget "$budgetName" saved successfully to Firestore.');

      // Optionally, clear the fields after successful save
      _budgetNameController.clear();
      _budgetAmountController.clear();

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
          ],
        ),
      ),
    );
  }
}
