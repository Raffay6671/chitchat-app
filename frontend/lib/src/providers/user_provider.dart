import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _id;
  String? _username;
  String? _email;
  String? _displayName;
  String? _profilePicture;

  // Getters for all user datas
  String? get id => _id;
  String? get username => _username;
  String? get email => _email;
  String? get displayName => _displayName;
  String? get profilePicture => _profilePicture;

  // ✅ Set all user data
  void setUserData({
    required String id,
    required String username,
    required String email,
    required String displayName,
    required String profilePicture,
  }) {
    _id = id;
    _username = username;
    _email = email;
    _displayName = displayName;
    _profilePicture = profilePicture;
    notifyListeners();
  }

  // ✅ Clear user data
  void clearUserData() {
    _id = null;
    _username = null;
    _email = null;
    _displayName = null;
    _profilePicture = null;
    notifyListeners();
  }
}
