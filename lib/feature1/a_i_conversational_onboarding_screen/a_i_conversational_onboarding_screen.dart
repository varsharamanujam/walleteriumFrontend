import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:walleterium/app_state.dart';

class AIOnboardingScreen extends StatefulWidget {
  const AIOnboardingScreen({Key? key}) : super(key: key);

  @override
  _AIOnboardingScreenState createState() => _AIOnboardingScreenState();
}

class _AIOnboardingScreenState extends State<AIOnboardingScreen> {
  final TextEditingController _textController = TextEditingController();
  final FFAppState _appState = FFAppState();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Clear chat history and send an initial empty message to get the bot's greeting
    _appState.chatMessages.clear();
    _sendMessageToServer("");
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) {
      return;
    }
    _textController.clear();
    setState(() {
      _appState.addToChatMessages({'text': text, 'isFromUser': true});
    });

    _sendMessageToServer(text);
  }

  void _sendMessageToServer(String text) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8081/agenticOnboarding'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'userId': 'test_user', // Replace with actual user ID
          'message': text,
          'history': _appState.chatMessages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _appState.addToChatMessages({'text': data['response'], 'isFromUser': false});
        });
      } else {
        // Handle server error
        setState(() {
          _appState.addToChatMessages({'text': 'Sorry, something went wrong. Please try again.', 'isFromUser': false});
        });
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      setState(() {
        _appState.addToChatMessages({'text': 'Could not connect to the bot. Please check your connection.', 'isFromUser': false});
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fin - Your Financial Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _appState.chatMessages.length,
              itemBuilder: (_, int index) {
                final message = _appState.chatMessages.reversed.toList()[index];
                return ListTile(
                  title: Text(message['text']),
                  leading: message['isFromUser']
                      ? const Icon(Icons.person)
                      : const Icon(Icons.android),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: IconTheme(
              data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _handleSubmitted,
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Send a message',
                        ),
                        enabled: !_isLoading,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
