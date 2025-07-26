import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'a_i_conversational_onboarding_screen_model.dart';
export 'a_i_conversational_onboarding_screen_model.dart';

// Imports for Firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/index.dart';

class AIConversationalOnboardingScreenWidget extends StatefulWidget {
  const AIConversationalOnboardingScreenWidget({super.key});

  static String routeName = 'AIConversationalOnboardingScreen';
  static String routePath = '/aIConversationalOnboardingScreen';

  @override
  State<AIConversationalOnboardingScreenWidget> createState() =>
      _AIConversationalOnboardingScreenWidgetState();
}

class _AIConversationalOnboardingScreenWidgetState
    extends State<AIConversationalOnboardingScreenWidget> {
  late AIConversationalOnboardingScreenModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model =
        createModel(context, () => AIConversationalOnboardingScreenModel());

    _model.userMessageInputTextController ??=
        TextEditingController(text: 'Complete Setup...');
    _model.userMessageInputFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 1,
                child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  children: [
                    Container(
                      width: 363.1,
                      height: 700.0,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'This screen is for the AI conversation to collect user profile data.',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          10.0, 0.0, 10.0, 0.0),
                      child: TextFormField(
                        controller: _model.userMessageInputTextController,
                        focusNode: _model.userMessageInputFocusNode,
                        readOnly:
                            true, // Making the text field non-editable for this example
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 10.0, 0.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                      final user = currentUser;
                      if (user == null) {
                        context.goNamed(AuthHubScreenWidget.routeName);
                        return;
                      }

                      final batch = FirebaseFirestore.instance.batch();
                      
                      // --- Create references with unique IDs FIRST ---
                      final hdfcAccountRef = FirebaseFirestore.instance.collection('user_accounts').doc();
                      final cashAccountRef = FirebaseFirestore.instance.collection('user_accounts').doc();
                      final vehicleAssetRef = FirebaseFirestore.instance.collection('user_assets').doc();
                      final goldAssetRef = FirebaseFirestore.instance.collection('user_assets').doc(); //

                      // --- Set Account Data ---
                      batch.set(hdfcAccountRef, {
                        'user_id': user.uid, 'account_name': 'HDFC Bank Savings', 'account_type': 'Debit',
                        'current_balance': 125500.75, 'created_at': FieldValue.serverTimestamp(), 'account_color': '#1e90ff',
                      });
                      batch.set(cashAccountRef, {
                        'user_id': user.uid, 'account_name': 'Cash Wallet', 'account_type': 'Cash',
                        'current_balance': 8500.00, 'created_at': FieldValue.serverTimestamp(), 'account_color': '#32cd32',
                      });

                      // --- Set Asset Data ---
                      batch.set(vehicleAssetRef, {
                        'user_id': user.uid, 'asset_name': 'My Suzuki Swift', 'asset_type': 'Vehicle',
                        'current_value': 680000.0, 'purchase_value': 820000.0,
                        'purchase_date': Timestamp.fromDate(DateTime(2023, 5, 20)),
                        'metadata': { 'make': 'Maruti Suzuki', 'model': 'Swift VXI', 'year': 2023 }
                      });
                      batch.set(goldAssetRef, {
                        'user_id': user.uid, 'asset_name': 'Gold Bar', 'asset_type': 'Gold', //
                        'current_value': 0.0, // This will be updated by live price in WealthHubScreen
                        'purchase_value': 60000.0, // Assuming 10 grams purchased at 6000/gram
                        'purchase_date': Timestamp.fromDate(DateTime(2024, 1, 15)), //
                        'metadata': { 'weightInGrams': 10.0 } //
                      });

                      // --- Set Transaction Data (linked to HDFC account) ---
                      batch.set(FirebaseFirestore.instance.collection('transactions').doc(), {
                        'user_id': user.uid, 'account_id': hdfcAccountRef.id, 'amount': 50000.0,
                        'type': 'Income', 'description': 'Monthly Salary', 'category': 'Salary',
                        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 1)),
                      });
                      batch.set(FirebaseFirestore.instance.collection('transactions').doc(), {
                        'user_id': user.uid, 'account_id': hdfcAccountRef.id, 'amount': 750.50,
                        'type': 'Expense', 'description': 'Dinner at Toit', 'category': 'Food & Drink',
                        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 20)),
                      });
                      batch.set(FirebaseFirestore.instance.collection('transactions').doc(), {
                        'user_id': user.uid, 'account_id': hdfcAccountRef.id, 'amount': 900.00,
                        'type': 'Expense', 'description': 'movie', 'category': 'entertainment',
                        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 20)),
                      });
                      batch.set(FirebaseFirestore.instance.collection('transactions').doc(), {
                        'user_id': user.uid, 'account_id': hdfcAccountRef.id, 'amount': 1500.00,
                        'type': 'Expense', 'description': 'family outing', 'category': 'entertainment',
                        'transaction_date': Timestamp.fromDate(DateTime(2025, 7, 20)),
                      });

                      // --- Finalize Onboarding ---
                      final walletUserDocRef = FirebaseFirestore.instance.collection('wallet_user_collection').doc(user.uid);
                      batch.update(walletUserDocRef, {
                        'onboarding_completed': true,
                        'persona': 'Budgetor',
                      });

                      try {
                        await batch.commit();
                        context.goNamed(MainDashWidget.routeName);
                      } catch (e) {
                        print('Error committing batch write: $e');
                      }
                    },
                      text: 'Finish',
                      icon: const Icon(
                        Icons.send,
                        size: 15.0,
                      ),
                      options: FFButtonOptions(
                        width: 100, // Adjusted width for better text fit
                        height: 40.0,
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: FlutterFlowTheme.of(context)
                                      .titleSmallFamily,
                                  color: Colors.white,
                                ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}