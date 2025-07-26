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
  String? _expandedCategory; // State to track the currently expanded category

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
        .orderBy('transaction_date', descending: true) // Ensure chronological order
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
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading account details.'));
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
        subtitle: const Text('Available Balance'),
        trailing: Text(
          NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(account.currentBalance),
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ToggleButtons(
        isSelected: [!_isCategoryView, _isCategoryView],
        onPressed: (index) {
          setState(() {
            _isCategoryView = index == 1;
            _expandedCategory = null; // Collapse all categories when switching view
          });
        },
        borderRadius: BorderRadius.circular(8.0),
        selectedColor: Colors.white,
        fillColor: FlutterFlowTheme.of(context).primary,
        color: FlutterFlowTheme.of(context).primaryText,
        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
        children: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('List')),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Category')),
        ],
      ),
    );
  }

  Widget _buildListView(List<TransactionsRecord> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions found for this account.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return _buildTransactionTile(tx);
      },
    );
  }

  Widget _buildCategoryView(List<TransactionsRecord> transactions) {
    // Group transactions by category, including both income and expense for display
    final Map<String, List<TransactionsRecord>> transactionsByCategory = {};
    final Map<String, double> categoryTotals = {};

    for (var tx in transactions) {
      transactionsByCategory.update(
        tx.category,
        (list) => list..add(tx),
        ifAbsent: () => [tx],
      );
      categoryTotals.update(
        tx.category,
        (value) => value + (tx.type == 'Income' ? tx.amount : -tx.amount),
        ifAbsent: () => (tx.type == 'Income' ? tx.amount : -tx.amount),
      );
    }

    // Sort categories alphabetically
    final sortedCategories = transactionsByCategory.keys.toList()..sort();

    final List<Color> pieColors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink
    ];

    // Prepare data for the pie chart (only for expenses if desired, or total)
    final Map<String, double> spendingByCategoryForChart = {};
    final expensesForChart = transactions.where((tx) => tx.type == 'Expense');
    for (var tx in expensesForChart) {
      spendingByCategoryForChart.update(
        tx.category,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final totalExpensesForChart = expensesForChart.fold(0.0, (sum, e) => sum + e.amount);
    
    final pieChartSections = spendingByCategoryForChart.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = pieColors[index % pieColors.length];
      final percentage = (data.value / totalExpensesForChart * 100);

      return PieChartSectionData(
        color: color,
        value: data.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
      );
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pie Chart (only if there are expenses to show)
          if (expensesForChart.isNotEmpty)
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          
          // List of expandable categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: sortedCategories.map((category) {
                final categoryTransactions = transactionsByCategory[category]!;
                // Sort transactions within each category chronologically
                categoryTransactions.sort((a, b) => a.transactionDate!.compareTo(b.transactionDate!));
                
                final categoryTotal = categoryTotals[category] ?? 0.0;
                final formattedCategoryTotal = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(categoryTotal);
                final categoryColor = categoryTotal >= 0 ? FlutterFlowTheme.of(context).success : FlutterFlowTheme.of(context).error;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: ExpansionTile(
                    key: PageStorageKey(category), // Keep expansion state across rebuilds
                    initiallyExpanded: _expandedCategory == category,
                    onExpansionChanged: (isExpanded) {
                      setState(() {
                        _expandedCategory = isExpanded ? category : null;
                      });
                    },
                    title: Text(category),
                    trailing: Text(
                      formattedCategoryTotal,
                      style: TextStyle(fontWeight: FontWeight.bold, color: categoryColor),
                    ),
                    children: categoryTransactions.map((tx) => _buildTransactionTile(tx)).toList(),
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

    return Padding( // Added Padding to the individual transaction tile for better spacing
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 1, // Slightly less elevation for nested cards
        margin: EdgeInsets.zero, // Remove outer margin if using Padding
        child: ListTile(
          leading: Icon(
            isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: color,
          ),
          title: Text(tx.description),
          subtitle: Text('${tx.category} - ${DateFormat('MMM d, yyyy').format(tx.transactionDate!)}'), // Added date to subtitle
          trailing: Text(
            '$sign ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(tx.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
