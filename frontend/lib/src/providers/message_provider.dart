import 'package:flutter/material.dart';

class MessageProvider with ChangeNotifier {
  List<Map<String, dynamic>> _messages = [];

  List<Map<String, dynamic>> get messages => _messages;

  // De-dup by ID so we never add the same message twice
  void addMessage(Map<String, dynamic> message) {
    if (message['id'] == null) {
      // no unique ID - can't deduplicatee
      _messages.add(message);
      notifyListeners();
      return;
    }
    // check if this ID already exists
    final existing = _messages.any((m) => m['id'] == message['id']);
    if (!existing) {
      _messages.add(message);
      notifyListeners();
    }
  }

  void setMessages(List<Map<String, dynamic>> newMessages) {
    // also check duplicates here if needed
    _messages = [];
    for (var msg in newMessages) {
      if (msg['id'] != null) {
        final existing = _messages.any((m) => m['id'] == msg['id']);
        if (!existing) _messages.add(msg);
      } else {
        _messages.add(msg);
      }
    }
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
