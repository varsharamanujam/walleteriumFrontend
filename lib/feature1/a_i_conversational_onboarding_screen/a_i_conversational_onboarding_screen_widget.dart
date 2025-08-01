import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/auth/firebase_auth/auth_util.dart';
import '/index.dart'; // Make sure this imports MainDashWidget
import 'a_i_conversational_onboarding_screen_model.dart';
export 'a_i_conversational_onboarding_screen_model.dart';
import 'message.dart';
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
    _callAgenticOnboarding(initialMessage: "Hello"); 
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _callAgenticOnboarding({String? initialMessage}) async {
    final text = initialMessage ?? _model.userMessageInputTextController!.text;
    if (text.isEmpty) {
      return;
    }

    final userMessage = Message(text: text, isFromUser: true);

    if (!mounted) {
      return;
    }
    setState(() {
      _model.conversation.add(userMessage);
      _isLoading = true;
    });

    if (initialMessage == null) {
      _model.userMessageInputTextController!.clear();
    }

    try {
            // Use 10.0.2.2 for Android emulator to connect to host localhost
      final url = Uri.parse('http://10.0.2.2:8081/agenticOnboarding');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': currentUserUid ?? 'dummy_user_id',
          'message': text,
          'history': _model.conversation.map((m) => {
            'text': m.text,
            'isFromUser': m.isFromUser
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse =
            Message(text: data['response'] as String, isFromUser: false);

        if (!mounted) {
          return;
        }
        setState(() {
          _model.conversation.add(aiResponse);
          _isConversationDone = data['isDone'] ?? false;
          _isLoading = false;
        });

        if (_isConversationDone) {
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.goNamed(MainDashWidget.routeName);
            }
          });
        }
      } else {
        throw Exception('Failed to load data from the server');
      }
    } catch (e) {
      print('Error calling agenticOnboarding: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Error communicating with the assistant. Please try again.')),
        );
      }
      
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _model.conversation.remove(userMessage);
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
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: _model.conversation.map((message) {
                          return ListTile(
                            title: Align(
                              alignment: message.isFromUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
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
                        }).toList(),
                      ),
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