import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Commented out as per request
// import 'package:cloud_functions/cloud_functions.dart'; // Commented out as per request
import '/auth/firebase_auth/auth_util.dart';
// import '/index.dart'; // Commented out as per request
// import 'a_i_conversational_onboarding_screen_model.dart'; // Commented out as per request
// export 'a_i_conversational_onboarding_screen_model.dart'; // Commented out as per request
import 'package:walleterium/feature1/a_i_conversational_onboarding_screen/dummyData.dart'; // Import dummyData.dart

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
  // late AIConversationalOnboardingScreenModel _model; // Commented out as per request
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // String? _onboardingSessionId; // Commented out as per request
  // bool _isLoading = true; // Commented out as per request
  // bool _isConversationDone = false; // Commented out as per request

  @override
  void initState() {
    super.initState();
    // _model = createModel(context, () => AIConversationalOnboardingScreenModel()); // Commented out as per request
    // _model.userMessageInputTextController ??= TextEditingController(); // Commented out as per request
    // _model.userMessageInputFocusNode ??= FocusNode(); // Commented out as per request
    // _startOrResumeOnboarding(); // Commented out as per request
  }

  @override
  void dispose() {
    // _model.dispose(); // Commented out as per request
    super.dispose();
  }

  // Commented out API related methods as per request
  /*
  Future<void> _startOrResumeOnboarding() async {
    if (currentUser == null) {
      setState(() {
        _isLoading = false; // Set loading to false if no user
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('startOnboarding');
      // For development, you can mock the current user if FirebaseAuth isn't fully set up locally
      final results = await callable.call({'userId': currentUserUid ?? 'dummy_user_id'});
      final data = results.data as Map<String, dynamic>;

      _onboardingSessionId = data['sessionId'];
      // Ensure 'messages' is treated as a List<dynamic> before mapping
      final messages = (data['messages'] as List<dynamic>)
          .map((m) => Message(
              text: m['text'] as String, isFromUser: m['sender'] == 'user'))
          .toList();

      setState(() {
        _model.conversation = messages;
        _isLoading = false;
        _isConversationDone = data['isDone'] ?? false;
      });
    } catch (e) {
      print('Error starting onboarding: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting onboarding. Please try again.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUserMessage() async {
    final text = _model.userMessageInputTextController.text;
    if (text.isEmpty || _onboardingSessionId == null) {
      return;
    }

    final userMessage = Message(text: text, isFromUser: true);

    setState(() {
      _model.conversation.add(userMessage);
      _isLoading = true;
    });
    _model.userMessageInputTextController.clear();

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('postToOnboarding');
      final results = await callable.call({
        'sessionId': _onboardingSessionId,
        'message': text,
      });

      final data = results.data as Map<String, dynamic>;
      final aiResponse =
          Message(text: data['response'] as String, isFromUser: false);

      setState(() {
        _model.conversation.add(aiResponse);
        _isConversationDone = data['isDone'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message. Please try again.')),
      );
      setState(() {
        _isLoading = false;
        _model.conversation.remove(userMessage); // Remove user message on error
      });
    }
  }

  Future<void> _completeOnboarding() async {
    // The backend should handle marking the user as complete.
    // This navigation assumes the backend has finished its work.
    context.goNamed(MainDashWidget.routeName);
  }

  // New method to populate dummy conversation data
  void _populateDummyConversation() {
    setState(() {
      _model.conversation = [
        Message(text: "Hello! I'm here to help you set up your wallet. What's your primary goal with this app?", isFromUser: false),
        Message(text: "My goal is to track my spending and save money.", isFromUser: true),
        Message(text: "That's a great goal! Are you interested in budgeting tools or investment insights?", isFromUser: false),
        Message(text: "Budgeting tools would be really helpful for me.", isFromUser: true),
        Message(text: "Excellent! We have several budgeting features. Is there any specific type of budget you're looking for, like a monthly budget or category-based tracking?", isFromUser: false),
        Message(text: "A monthly budget would be ideal.", isFromUser: true),
        Message(text: "Got it! Your onboarding is now complete. We've set up your profile to focus on monthly budgeting. You can always adjust these settings later. Enjoy using the app!", isFromUser: false),
      ];
      _isConversationDone = true; // Mark as done for dummy data
      _isLoading = false; // Ensure loading is off
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dummy conversation loaded!')),
    );
  }

  // Existing method to upload dummy Firestore data (from your provided code)
  Future<void> _uploadDummyFirestoreData() async {
    try {
      final data = {
        'name': 'Test User from Onboarding',
        'email': 'testuser_onboarding@example.com',
        'timestamp': FieldValue.serverTimestamp(),
        'role': 'onboarding_tester',
      };
      await FirebaseFirestore.instance.collection('demoEntries').add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dummy Firestore data uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading Firestore data: $e')),
      );
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: FFButtonWidget(
            onPressed: () async {
              await uploadDummyData(context);
            },
            text: 'Populate Dummy Data & Continue',
            options: FFButtonOptions(
              width: 250,
              height: 50,
              color: FlutterFlowTheme.of(context).primary,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.white,
                    fontSize: 16,
                  ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
