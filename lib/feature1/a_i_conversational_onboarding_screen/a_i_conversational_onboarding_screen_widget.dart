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

                        // --- 2. Dummy Financial Accounts ('user_accounts') ---
                        final debitAccountRef = FirebaseFirestore.instance.collection('user_accounts').doc();
                        batch.set(debitAccountRef, {
                          'user_id': user.uid,
                          'account_name': 'HDFC Bank Savings',
                          'account_type': 'Debit',
                          'current_balance': 125500.75, // Stays a double
                          'currency': 'INR',
                          'institution_name': 'HDFC Bank',
                          'created_at': FieldValue.serverTimestamp(),
                          'account_color': '#1e90ff',
                        });

                        final cashAccountRef = FirebaseFirestore.instance.collection('user_accounts').doc();
                        batch.set(cashAccountRef, {
                          'user_id': user.uid,
                          'account_name': 'Cash Wallet',
                          'account_type': 'Cash',
                          'current_balance': 8500.00, // Explicitly a double
                          'currency': 'INR',
                          'created_at': FieldValue.serverTimestamp(),
                          'account_color': '#32cd32',
                        });

                        // --- 3. Dummy Physical Assets ('user_assets') ---
                        final vehicleAssetRef = FirebaseFirestore.instance.collection('user_assets').doc();
                        batch.set(vehicleAssetRef, {
                          'user_id': user.uid,
                          'asset_name': 'My Suzuki Swift',
                          'asset_type': 'Vehicle',
                          // --- FIX: Values are now explicitly doubles ---
                          'current_value': 680000.0,
                          'purchase_value': 820000.0,
                          'purchase_date': Timestamp.fromDate(DateTime(2023, 5, 20)),
                          'metadata': {
                            'make': 'Maruti Suzuki',
                            'model': 'Swift VXI',
                            'year': 2023,
                            'kms_driven': 12400,
                          }
                        });

                        // --- 4. Finalize Onboarding Status & Set Persona ---
                        final walletUserDocRef = FirebaseFirestore.instance.collection('wallet_user_collection').doc(user.uid);
                        batch.update(walletUserDocRef, {
                          'onboarding_completed': true,
                          'persona': 'Budgetor'
                        });

                        // Commit and navigate
                        try {
                          await batch.commit();
                          context.goNamed(MainDashWidget.routeName);
                        } catch (e) {
                          print('Error committing batch write: $e');
                          // Optionally, show an error message to the user
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Could not complete setup. Please try again.')),
                          );
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