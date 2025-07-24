import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  static String routeName = 'AllTransactions';
  static String routePath = '/allTransactions';

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  Future<List<TransactionsRecord>>? _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _fetchAllTransactions();
  }

  Future<List<TransactionsRecord>> _fetchAllTransactions() async {
    final user = currentUser;
    if (user == null) {
      return []; // Return empty list if no user
    }

    final transactionsSnapshot = await TransactionsRecord.collection
      .where('user_id', isEqualTo: user.uid)
      .orderBy('transaction_date', descending: true)
      .get();
      
  return transactionsSnapshot.docs
      .map((doc) => TransactionsRecord.fromSnapshot(doc))
      .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
        title: Text(
          'All Transactions',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<TransactionsRecord>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          final transactions = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionTile(tx);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(TransactionsRecord tx) {
    final isIncome = tx.type == 'Income';
    final color = isIncome ? FlutterFlowTheme.of(context).success : FlutterFlowTheme.of(context).error;
    final sign = isIncome ? '+' : '-';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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