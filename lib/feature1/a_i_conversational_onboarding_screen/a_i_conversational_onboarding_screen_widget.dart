import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/index.dart'; // Make sure this imports MainDashWidget
import 'a_i_conversational_onboarding_screen_model.dart';
export 'a_i_conversational_onboarding_screen_model.dart';

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
  bool _isLoading = true;
  bool _isConversationDone = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AIConversationalOnboardingScreenModel());
    _model.userMessageInputTextController ??= TextEditingController();
    _model.userMessageInputFocusNode ??= FocusNode();
    // Start the conversation with an initial message
    // _callAgenticOnboarding(initialMessage: "Hello"); // Removed initial call
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _callAgenticOnboarding({String? initialMessage}) async {
    /**
     * Calls the agenticOnboarding Firebase Function to interact with the AI assistant.
     *
     * @param initialMessage An optional initial message to start the conversation. If null, the message from the user input is used.
     *
     * @return void
     *
     * Example:
     * _callAgenticOnboarding(initialMessage: "Hello");
     */
    final text = initialMessage ?? _model.userMessageInputTextController!.text;
    if (text.isEmpty) {
      return;
    }

    final userMessage = Message(text: text, isFromUser: true);

    // Check mounted state before any UI updates right at the start of async method
    if (!mounted) {
      return;
    }
    setState(() {
      if (initialMessage == null) {
        _model.conversation.add(userMessage);
      }
      _isLoading = true;
    });

    if (initialMessage == null) {
      _model.userMessageInputTextController!.clear();
    }

    try {
      final HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('agenticOnboarding');
      final results = await callable.call({
        'userId': currentUserUid ?? 'dummy_user_id',
        'message': text,
      });

      final data = results.data as Map<String, dynamic>;
      final aiResponse =
          Message(text: data['response'] as String, isFromUser: false);

      // Check mounted state before any UI updates after async call
      if (!mounted) {
        return;
      }
      setState(() {
        _model.conversation.add(aiResponse);
        _isConversationDone = data['isDone'] ?? false;
        _isLoading = false;
      });

      if (_isConversationDone) {
        // Navigate to the dashboard after a short delay
        Future.delayed(const Duration(seconds: 2), () { // Added 'const' for efficiency
          if (mounted) {
            // Check mounted state before using context for navigation
            context.goNamed(MainDashWidget.routeName);
          }
        });
      }
    } catch (e) {
      print('Error calling agenticOnboarding: $e');

      // !!! FIX: Add mounted check before ScaffoldMessenger.of(context) !!!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error communicating with the assistant. Please try again.')),
        );
      }
      
      // Check mounted state before any UI updates in catch block
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        if (initialMessage == null) {
          _model.conversation.remove(userMessage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthUserStreamWidget(
      builder: (context) {
        if (currentUserUid.isEmpty) {
          return const Scaffold( // Added 'const'
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        // Call _callAgenticOnboarding here, after currentUserUid is available
        // This ensures the initial "Hello" is sent once the user is authenticated.
        // It should be fine as it's called in addPostFrameCallback.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // You might want to ensure this 'Hello' is sent only once
          // For example, using a flag if it's causing repeated calls
          // or if the conversation should only start when the user is truly ready.
          // For now, if the conversation is empty and not loading, call it.
          if (_model.conversation.isEmpty && !_isLoading) {
             _callAgenticOnboarding(initialMessage: "Hello");
          }
        });

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar:
             AppBar(
              title: const Text('AI Onboarding'), // Added 'const'
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: _isLoading && _model.conversation.isEmpty
                        ? const Center(child: CircularProgressIndicator()) // Added 'const'
                        : ListView.builder(
                            itemCount: _model.conversation.length,
                            itemBuilder: (context, index) {
                              final message = _model.conversation[index];
                              return ListTile(
                                title: Align(
                                  alignment: message.isFromUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.all(10), // Added 'const'
                                    decoration: BoxDecoration(
                                      color: message.isFromUser
                                          ? FlutterFlowTheme.of(context).primary
                                          : FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      message.text,
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: message.isFromUser
                                                ? Colors.white
                                                : FlutterFlowTheme.of(context)
                                                    .primaryText,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_isLoading && _model.conversation.isNotEmpty)
                    const Padding( // Added 'const'
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (!_isConversationDone)
                    Padding(
                      padding: const EdgeInsets.all(8.0), // Added 'const'
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _model.userMessageInputTextController,
                              focusNode: _model.userMessageInputFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onFieldSubmitted: (_) => _callAgenticOnboarding(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send), // Added 'const'
                            onPressed: () => _callAgenticOnboarding(),
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16.0), // Added 'const'
                      child: FFButtonWidget(
                        onPressed: () =>
                            context.goNamed(MainDashWidget.routeName),
                        text: 'Continue to Dashboard',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle:
                              FlutterFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Colors.white,
                                  ),
                          elevation: 3,
                          borderSide: const BorderSide( // Added 'const'
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}