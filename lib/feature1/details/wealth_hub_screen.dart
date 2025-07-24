// In lib/details/wealth_hub_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';

class WealthHubScreen extends StatefulWidget {
  const WealthHubScreen({super.key});

  static String routeName = 'WealthHub';
  static String routePath = '/wealthHub';

  @override
  State<WealthHubScreen> createState() => _WealthHubScreenState();
}

class _WealthHubScreenState extends State<WealthHubScreen> {
  Future<List<UserAssetsRecord>>? _assetsFuture;

  @override
  void initState() {
    super.initState();
    _assetsFuture = _fetchAllAssets();
  }

  Future<List<UserAssetsRecord>> _fetchAllAssets() async {
    final user = currentUser;
    if (user == null) return [];

    final assetsSnapshot = await UserAssetsRecord.collection
      .where('user_id', isEqualTo: user.uid)
      .get();
      
  return assetsSnapshot.docs
      .map((doc) => UserAssetsRecord.fromSnapshot(doc))
      .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).primaryText),
        title: Text(
          'My Assets',
          style: FlutterFlowTheme.of(context).headlineSmall,
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<UserAssetsRecord>>(
        future: _assetsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No assets found.'));
          }

          final assets = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: assets.length,
            itemBuilder: (context, index) {
              final asset = assets[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                child: ListTile(
                  title: Text(asset.assetName),
                  subtitle: Text(asset.assetType),
                  trailing: Text(
                    NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(asset.currentValue),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}