import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'a_i_conversational_onboarding_screen_widget.dart'
    show AIConversationalOnboardingScreenWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// class Message { // Commented out as per request
//   final String text; // Commented out as per request
//   final bool isFromUser; // Commented out as per request
//   Message({required this.text, required this.isFromUser}); // Commented out as per request
// } // Commented out as per request

class AIConversationalOnboardingScreenModel
    extends FlutterFlowModel<AIConversationalOnboardingScreenWidget> {
  ///  State fields for stateful widgets in this page.

  TextEditingController userMessageInputTextController = TextEditingController();
  FocusNode? userMessageInputFocusNode;

  // String? Function(BuildContext, String?)? // Commented out as per request
  //     userMessageInputTextControllerValidator; // Commented out as per request

  // List<Message> conversation = []; // Commented out as per request

  @override
  void initState(BuildContext context) {
    // If userMessageInputFocusNode is always expected to be non-null
    // by the time initState completes, you could initialize it here too:
    // userMessageInputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Safely dispose of nullable FocusNode
    userMessageInputFocusNode?.dispose();

    // Dispose of non-nullable TextEditingController
    userMessageInputTextController.dispose();

    // Call super.dispose() *last*
    // super.dispose(); only if its not abstract class
  }
}