// In lib/details/spending_analyzer_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';

class SpendingAnalyzerScreen extends StatefulWidget {
  const SpendingAnalyzerScreen({
    super.key,
    required this.accountId,
  });

  final String accountId;

  static String routeName = 'SpendingAnalyzer';
  static String routePath = '/spendingAnalyzer';

  @override
  State<SpendingAnalyzerScreen> createState() => _SpendingAnalyzerScreenState();
}

class _SpendingAnalyzerScreenState extends State<SpendingAnalyzerScreen> {
  Future<Map<String, dynamic>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
  // Step 1: Fetch the account document first using the ID we received.
  final accountDoc = await UserAccountsRecord.collection.doc(widget.accountId).get();

  if (!accountDoc.exists) {
    throw Exception('Account not found');
  }
  
  final account = UserAccountsRecord.fromSnapshot(accountDoc);
  
  // Step 2: Get the user_id directly from the account document.
  final userId = account.userId;
  if (userId.isEmpty) {
    throw Exception('User ID not found in account document');
  }

  // Step 3: Now, use the retrieved userId to securely fetch the transactions.
  final transactionsFuture = TransactionsRecord.collection
      .where('user_id', isEqualTo: userId)
      .where('account_id', isEqualTo: widget.accountId)
      .orderBy('transaction_date', descending: true)
      .get();
      
  final transactionsSnapshot = await transactionsFuture;

  return {
    'account': account,
    'transactions': transactionsSnapshot.docs
        .map((doc) => TransactionsRecord.fromSnapshot(doc))
        .toList(),
  };
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
        title: Text(
          'Account Details',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Error loading account details.'));
          }

          final account = snapshot.data!['account'] as UserAccountsRecord;
          final transactions = snapshot.data!['transactions'] as List<TransactionsRecord>;
          final income = transactions.where((t) => t.type == 'Income').fold(0.0, (sum, item) => sum + item.amount);
          final expense = transactions.where((t) => t.type == 'Expense').fold(0.0, (sum, item) => sum + item.amount);

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildAccountInfoCard(account),
              SizedBox(height: 24),
              _buildSummaryCards(income, expense),
              SizedBox(height: 24),
              Text('Recent Transactions', style: FlutterFlowTheme.of(context).titleLarge),
              SizedBox(height: 8),
              if (transactions.isEmpty)
                Text('No transactions found for this account.')
              else
                ...transactions.map((tx) => _buildTransactionTile(tx)).toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccountInfoCard(UserAccountsRecord account) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(account.accountName, style: FlutterFlowTheme.of(context).titleLarge),
        subtitle: Text('Available Balance'),
        trailing: Text(
          NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(account.currentBalance),
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
      ),
    );
  }

  Widget _buildSummaryCards(double income, double expense) {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Color(0xFFE8F5E9),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Text('Income', style: FlutterFlowTheme.of(context).labelLarge),
                SizedBox(height: 4),
                Text(
                  NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(income),
                  style: FlutterFlowTheme.of(context).titleMedium?.copyWith(color: FlutterFlowTheme.of(context).success),
                ),
              ]),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Card(
            color: Color(0xFFFCE8E8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Text('Expense', style: FlutterFlowTheme.of(context).labelLarge),
                SizedBox(height: 4),
                Text(
                  NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(expense),
                   style: FlutterFlowTheme.of(context).titleMedium?.copyWith(color: FlutterFlowTheme.of(context).error),
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(TransactionsRecord tx) {
    final isIncome = tx.type == 'Income';
    final color = isIncome ? FlutterFlowTheme.of(context).success : FlutterFlowTheme.of(context).error;
    final sign = isIncome ? '+' : '-';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: color),
        title: Text(tx.description),
        subtitle: Text(tx.category),
        trailing: Text(
          '$sign ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(tx.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}