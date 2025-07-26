import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:walleterium/main_dash/main_dash_widget.dart';

class DummyDataUploaderWidget extends StatefulWidget {
  const DummyDataUploaderWidget({Key? key}) : super(key: key);

  @override
  _DummyDataUploaderWidgetState createState() =>
      _DummyDataUploaderWidgetState();
}

class _DummyDataUploaderWidgetState extends State<DummyDataUploaderWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: FFButtonWidget(
          onPressed: () async {
            await uploadDummyData(context);
          },
          text: 'Upload Financial Data',
          options: FFButtonOptions(
            width: 250,
            height: 50,
            color: Colors.blue,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.white,
                  fontSize: 16,
                ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

Future<void> uploadDummyData(BuildContext context) async {
  final user = currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please sign in first.')),
    );
    return;
  }

  final batch = FirebaseFirestore.instance.batch();

  // --- Create document references ---
  final hdfcAccountRef = FirebaseFirestore.instance.collection('user_accounts').doc();
  final cashAccountRef = FirebaseFirestore.instance.collection('user_accounts').doc();
  final landAssetRef = FirebaseFirestore.instance.collection('user_assets').doc();
  final goldAssetRef = FirebaseFirestore.instance.collection('user_assets').doc();
  final stockAssetRef = FirebaseFirestore.instance.collection('user_assets').doc();
  final walletUserDocRef = FirebaseFirestore.instance.collection('wallet_user_collection').doc(user.uid);

  try {
    // --- Accounts ---
    batch.set(hdfcAccountRef, {
      'user_id': user.uid,
      'account_name': 'HDFC Bank Savings',
      'account_type': 'Debit',
      'current_balance': 125500.75,
      'created_at': FieldValue.serverTimestamp(),
      'account_color': '#1e90ff',
    });

    batch.set(cashAccountRef, {
      'user_id': user.uid,
      'account_name': 'Cash Wallet',
      'account_type': 'Cash',
      'current_balance': 8500.00,
      'created_at': FieldValue.serverTimestamp(),
      'account_color': '#32cd32',
    });

    // --- Transactions ---
    final transactions = [
      {
        'amount': 50000.0,
        'type': 'Income',
        'description': 'Monthly Salary',
        'category': 'Salary',
        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 1)),
      },
      {
        'amount': 750.50,
        'type': 'Expense',
        'description': 'Dinner at Toit',
        'category': 'Food & Drink',
        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 20)),
      },
      {
        'amount': 900.00,
        'type': 'Expense',
        'description': 'movie',
        'category': 'entertainment',
        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 20)),
      },
      {
        'amount': 1500.00,
        'type': 'Expense',
        'description': 'family outing',
        'category': 'entertainment',
        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 20)),
      },
    ];

    for (final tx in transactions) {
      batch.set(
        FirebaseFirestore.instance.collection('transactions').doc(),
        {
          'user_id': user.uid,
          'account_id': hdfcAccountRef.id,
          ...tx,
        },
      );
    }

    // --- Assets ---
    batch.set(landAssetRef, {
      'user_id': user.uid,
      'asset_type': 'Land',
      'purchase_date': Timestamp.fromDate(DateTime(2020, 6, 15)),
      'purchase_price': 1200000,
      'metadata': {
        'size': {'value': 5000, 'unit': 'sqft'},
        'is_cultivable': true,
        'legal_restrictions': 'No construction allowed on 20% area',
        'development_approved': false,
        'resource_availability': {
          'water': true,
          'minerals': 'None',
          'utilities': 'Electricity, Sewage',
          'transportation': 'Highway nearby',
          'connectivity': '4G, Fiber Internet',
          'locality_type': 'urban',
        }
      },
    });

    batch.set(goldAssetRef, {
      'user_id': user.uid,
      'asset_type': 'Gold',
      'purchase_date': Timestamp.fromDate(DateTime(2021, 1, 10)),
      'volume_g': 50.0,
      'purchase_price_per_g': 4700,
      'current_value': 5250,
    });

    batch.set(stockAssetRef, {
      'user_id': user.uid,
      'asset_type': 'Stock',
      'ticker': 'INFY',
      'unit_price_purchase': 1500,
      'units_bought': 10,
      'exchange_date': Timestamp.fromDate(DateTime(2023, 3, 12)),
    });

    // --- Final onboarding update ---
    batch.set(walletUserDocRef, {
      'user_id': user.uid,
      'onboarding_completed': true,
      'persona': 'Budgetor',
    }, SetOptions(merge: true));

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dummy financial data uploaded successfully!')),
    );
    print('Attempting to navigate to MainDashWidget...');
    // After successful upload, navigate to the main dashboard
    context.goNamed(MainDashWidget.routeName);
    print('Navigation to MainDashWidget initiated.');
  } catch (e) {
    print('Error during dummy data upload or navigation: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error uploading data: $e')),
    );
  }
}

