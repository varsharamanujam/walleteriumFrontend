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
                        readOnly: true, // Making the text field non-editable for this example
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
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                    child: FFButtonWidget(
                      // --- FIX START: This onPressed logic is now corrected ---
                      onPressed: () async {
                        final user = currentUser;
                        if (user == null) {
                          context.goNamed(AuthHubScreenWidget.routeName);
                          return;
                        }

                        // 1. This map contains ONLY the onboarding data.
                        final onboardingData = {
                          'investment_style': 'Aggressive Growth',
                          'preferred_sectors': ['Technology', 'Healthcare', 'Renewable Energy'],
                          'communication_preference': 'Email',
                          'financial_literacy_score': 85,
                          'onboarding_complete_time': FieldValue.serverTimestamp(),
                        };
                        await FirebaseFirestore.instance
                            .collection('user_profiles')
                            .doc(user.uid)
                            .set(onboardingData);
                        final walletUserDocRef = FirebaseFirestore.instance
                            .collection('wallet_user_collection')
                            .doc(user.uid);
                        await walletUserDocRef.update({'onboarding_completed': true});
                        context.goNamed(MainDashWidget.routeName);
                      },
                      // --- FIX END ---
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