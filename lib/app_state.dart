import 'package:flutter/material.dart';
import '/backend/backend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'dart:convert';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  List<dynamic> _chatMessages = [];
  List<dynamic> get chatMessages => _chatMessages;
  set chatMessages(List<dynamic> value) {
    _chatMessages = value;
  }

  void addToChatMessages(dynamic value) {
    chatMessages.add(value);
  }

  void removeFromChatMessages(dynamic value) {
    chatMessages.remove(value);
  }

  void removeAtIndexFromChatMessages(int index) {
    chatMessages.removeAt(index);
  }

  void updateChatMessagesAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    chatMessages[index] = updateFn(_chatMessages[index]);
  }

  void insertAtIndexInChatMessages(int index, dynamic value) {
    chatMessages.insert(index, value);
  }
}
