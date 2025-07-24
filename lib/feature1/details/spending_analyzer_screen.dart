import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class SpendingAnalyzerScreen extends StatelessWidget {
  const SpendingAnalyzerScreen({super.key});

  static String routeName = 'SpendingAnalyzer';
  static String routePath = '/spendingAnalyzer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
        title: Text(
          'Spending Analyzer',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Details for Debit & Cash Accounts will be shown here.',
          style: FlutterFlowTheme.of(context).bodyLarge,
        ),
      ),
    );
  }
}