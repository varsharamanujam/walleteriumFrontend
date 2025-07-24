import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'a_i_conversational_onboarding_screen_widget.dart'
    show AIConversationalOnboardingScreenWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AIConversationalOnboardingScreenModel
    extends FlutterFlowModel<AIConversationalOnboardingScreenWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for userMessageInput widget.
  FocusNode? userMessageInputFocusNode;
  TextEditingController? userMessageInputTextController;
  String? Function(BuildContext, String?)?
      userMessageInputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    userMessageInputFocusNode?.dispose();
    userMessageInputTextController?.dispose();
  }
}
