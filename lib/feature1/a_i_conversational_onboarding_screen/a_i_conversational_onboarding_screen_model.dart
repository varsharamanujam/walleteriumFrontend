import '/flutter_flow/flutter_flow_util.dart';
import 'a_i_conversational_onboarding_screen_widget.dart'
    show AIConversationalOnboardingScreenWidget;
import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isFromUser;
  Message({required this.text, required this.isFromUser});
}

class AIConversationalOnboardingScreenModel
    extends FlutterFlowModel<AIConversationalOnboardingScreenWidget> {
  ///  State fields for stateful widgets in this page.

  TextEditingController? userMessageInputTextController;
  FocusNode? userMessageInputFocusNode;

  String? Function(BuildContext, String?)?
      userMessageInputTextControllerValidator;

  List<Message> conversation = [];

  @override
  void initState(BuildContext context) {
    userMessageInputFocusNode = FocusNode();
  }

  @override
  void dispose() {
    userMessageInputFocusNode?.dispose();
    userMessageInputTextController?.dispose();
  }
}