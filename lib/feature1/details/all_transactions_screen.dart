import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; 
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
  Future<Map<String, dynamic>>? _dataFuture;
  
  // --- NEW: State for toggling the view ---
  bool _isCategoryView = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchScreenData();
  }

  Future<Map<String, dynamic>> _fetchScreenData() async {
    final user = currentUser;
    if (user == null) {
      return {'accounts': [], 'transactions': []};
    }

    final accountsFuture = UserAccountsRecord.collection.where('user_id', isEqualTo: user.uid).get();
    final transactionsFuture = TransactionsRecord.collection
        .where('user_id', isEqualTo: user.uid)
        .orderBy('transaction_date', descending: true)
        .get();

    final results = await Future.wait([accountsFuture, transactionsFuture]);

    final accountsSnapshot = results[0] as QuerySnapshot;
    final transactionsSnapshot = results[1] as QuerySnapshot;

    return {
      'accounts': accountsSnapshot.docs.map((doc) => UserAccountsRecord.fromSnapshot(doc)).toList(),
      'transactions': transactionsSnapshot.docs.map((doc) => TransactionsRecord.fromSnapshot(doc)).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
        title: Text('All Transactions', style: FlutterFlowTheme.of(context).headlineSmall),
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Could not load data.'));
          }

          final accounts = snapshot.data!['accounts'] as List<UserAccountsRecord>;
          final transactions = snapshot.data!['transactions'] as List<TransactionsRecord>;
          final totalBalance = accounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);

          return Column(
            children: [
              _buildTotalBalanceCard(totalBalance),
              _buildViewToggle(), // The new toggle button
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

  // --- NEW: A toggle button to switch between views ---
  Widget _buildViewToggle() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    child: ToggleButtons(
      // --- FIX: Removed the extra underscore before the '!' ---
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
      return Center(child: Text('No transactions found.'));
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
  // 1. Process data: Filter for expenses and group by category
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
  int colorIndex = 0;
  final pieChartSections = spendingByCategory.entries.map((entry) {
    final color = pieColors[colorIndex % pieColors.length];
    colorIndex++;
    final totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final percentage = (entry.value / totalExpenses * 100);

    return PieChartSectionData(
      color: color,
      value: entry.value,
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
          height: 250, // Give the chart ample, fixed space
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

  Widget _buildTotalBalanceCard(double totalBalance) {
    // ... (This function remains the same)
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Available Balance',
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
            Text(
              NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(totalBalance),
              style: FlutterFlowTheme.of(context).headlineSmall?.copyWith(
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionsRecord tx) {
    // ... (This function remains the same)
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