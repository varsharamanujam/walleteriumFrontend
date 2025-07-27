// lib/feature1/budget_goals_screen.dart

import 'package:flutter/material.dart';
import 'package:walleterium/flutter_flow/flutter_flow_theme.dart';
import 'package:walleterium/flutter_flow/flutter_flow_widgets.dart'; // Assuming FFButtonWidget is here

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
  void _saveBudget() {
    final String budgetName = _budgetNameController.text.trim();
    final double? budgetAmount = double.tryParse(_budgetAmountController.text.trim());

    if (budgetName.isEmpty || budgetAmount == null) {
      _showSnackBar('Please enter both a budget name and a valid amount.');
      return;
    }

    // For now, we'll just print the values.
    // In a real app, you would save this to a database (e.g., Firestore).
    print('Budget Saved:');
    print('  Name: $budgetName');
    print('  Amount: $budgetAmount');

    _showSnackBar('Budget "$budgetName" saved successfully!');

    // You might want to navigate back after saving
    // Navigator.pop(context);
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
