import 'package:flutter/material.dart';

class GroupMessageProvider with ChangeNotifier {
  // ✅ Store group messages keyed by groupId
  final Map<String, List<Map<String, dynamic>>> _groupMessages = {};

  // ✅ Getter for messages of a specific group
  List<Map<String, dynamic>> getMessages(String groupId) {
    return _groupMessages[groupId] ?? [];
  }

  // ✅ Set messages for a specific group
  void setMessages(String groupId, List<Map<String, dynamic>> messages) {
    _groupMessages[groupId] = messages;
    notifyListeners();
  }

  // ✅ Add a new message to a group chat
  void addMessage(String groupId, Map<String, dynamic> message) {
    if (!_groupMessages.containsKey(groupId)) {
      _groupMessages[groupId] = [];
    }

    _groupMessages[groupId]!.add(message);
    notifyListeners();
  }

  // ✅ Clear messages of a specific group (e.g., on logout)
  void clearMessages(String groupId) {
    _groupMessages[groupId] = [];
    notifyListeners();
  }
}
