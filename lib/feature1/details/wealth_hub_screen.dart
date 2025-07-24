import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';

class WealthHubScreen extends StatelessWidget {
  const WealthHubScreen({super.key});

  static String routeName = 'WealthHub';
  static String routePath = '/wealthHub';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
        title: Text(
          'Wealth Hub',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Details for Capital Accounts & Assets will be shown here.',
          style: FlutterFlowTheme.of(context).bodyLarge,
        ),
      ),
    );
  }
}