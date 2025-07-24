import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // Make sure fl_chart is imported
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
  
  bool _isCategoryView = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final accountDoc = await UserAccountsRecord.collection.doc(widget.accountId).get();
    if (!accountDoc.exists) {
      throw Exception('Account not found');
    }
    
    final account = UserAccountsRecord.fromSnapshot(accountDoc);
    final userId = account.userId;
    if (userId.isEmpty) {
      throw Exception('User ID not found in account document');
    }

    final transactionsSnapshot = await TransactionsRecord.collection
        .where('user_id', isEqualTo: userId)
        .where('account_id', isEqualTo: widget.accountId)
        .orderBy('transaction_date', descending: true)
        .get();

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
        title: Text('Account Details', style: FlutterFlowTheme.of(context).headlineSmall),
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

          return Column(
            children: [
              _buildAccountInfoCard(account),
              _buildViewToggle(), // The view toggle
              Expanded(
                child: _isCategoryView
                    ? _buildCategoryView(transactions) // Show category view if toggled
                    : _buildListView(transactions),   // Otherwise, show the list
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccountInfoCard(UserAccountsRecord account) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

  // --- NEW: Toggle button to switch views ---
  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ToggleButtons(
        isSelected: [!_isCategoryView, _isCategoryView],
        onPressed: (index) {
          setState(() {
            _isCategoryView = index == 1;
          });
        },
        borderRadius: BorderRadius.circular(8.0),
        selectedColor: Colors.white,
        fillColor: FlutterFlowTheme.of(context).primary,
        color: FlutterFlowTheme.of(context).primaryText,
        constraints: BoxConstraints(minHeight: 40.0, minWidth: 100.0),
        children: [
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('List')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Category')),
        ],
      ),
    );
  }

  // --- NEW: The view for the chronological list of transactions ---
  Widget _buildListView(List<TransactionsRecord> transactions) {
    if (transactions.isEmpty) {
      return Center(child: Text('No transactions found for this account.'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _buildTransactionTile(tx);
      },
    );
  }

Widget _buildCategoryView(List<TransactionsRecord> transactions) {
  // 1. Process data for expenses
  final Map<String, double> spendingByCategory = {};
  final expenses = transactions.where((tx) => tx.type == 'Expense');

  if (expenses.isEmpty) {
    return Center(child: Text('No expense data to categorize.'));
  }

  for (var tx in expenses) {
    spendingByCategory.update(
      tx.category,
      (value) => value + tx.amount,
      ifAbsent: () => tx.amount,
    );
  }
  
  // 2. Prepare data for the pie chart
  final List<Color> pieColors = [
    Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink
  ];
  final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
  
  final pieChartSections = spendingByCategory.entries.toList().asMap().entries.map((entry) {
    final index = entry.key;
    final data = entry.value;
    final color = pieColors[index % pieColors.length];
    final percentage = (data.value / totalExpenses * 100);

    return PieChartSectionData(
      color: color,
      value: data.value,
      title: '${percentage.toStringAsFixed(0)}%',
      radius: 80,
      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)]),
    );
  }).toList();

  // 3. Build the final UI using a SingleChildScrollView and Column
  return SingleChildScrollView(
    child: Column(
      children: [
        // Widget for the Pie Chart
        Container(
          height: 250, // Give the chart a fixed, non-overlapping space
          padding: EdgeInsets.all(16),
          child: PieChart(
            PieChartData(
              sections: pieChartSections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        
        // Widget for the list of categories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: spendingByCategory.entries.map((entry) {
              final categoryIndex = spendingByCategory.keys.toList().indexOf(entry.key);
              final color = pieColors[categoryIndex % pieColors.length];
              
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: ListTile(
                  leading: Icon(Icons.circle, color: color, size: 16),
                  title: Text(entry.key),
                  trailing: Text(
                    NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(entry.value),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}
  
  Widget _buildTransactionTile(TransactionsRecord tx) {
    final isIncome = tx.type == 'Income';
    final color = isIncome ? FlutterFlowTheme.of(context).success : FlutterFlowTheme.of(context).error;
    final sign = isIncome ? '+' : '-';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: ListTile(
        leading: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: color,
        ),
        title: Text(tx.description),
        subtitle: Text(tx.category),
        trailing: Text(
          '$sign ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(tx.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}