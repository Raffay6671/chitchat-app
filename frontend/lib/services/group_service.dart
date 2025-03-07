import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class GroupService {
  static const String baseUrl = '${AppConfig.serverIp}/api/groups';

  // ✅ Fetch all groups the user is part of
  static Future<List<Map<String, dynamic>>> fetchGroups() async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data["groups"]);
    } else {
      throw Exception("Failed to fetch groups");
    }
  }

  // ✅ Fetch messages for a specific group
  static Future<List<Map<String, dynamic>>> fetchGroupMessages(
    String groupId,
  ) async {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$groupId/messages'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(
        data["messages"],
      ); // ✅ Return only messages
    } else {
      throw Exception("Failed to fetch group messages");
    }
  }

  // ✅ Send a group message to backend API
  static Future<void> sendGroupMessage(
    String groupId,
    Map<String, dynamic> message,
  ) async {
    final token = await _getAccessToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$groupId/messages'), // ✅ Fixed correct endpoint
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(message),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to send message");
    }
  }

  // ✅ Create a new group
  static Future<http.Response> createGroup(
    String groupName,
    List<String> members,
  ) async {
    final token = await _getAccessToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": groupName, "members": members}),
    );

    return response;
  }

  // ✅ Get authentication token from local storage
  static Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }
}
