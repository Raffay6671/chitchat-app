import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/providers/user_provider.dart'; // ✅ Import UserProvider for state management
import 'package:flutter/foundation.dart'; // For checking if the app is running on physical device or emulator

class AuthService {
  static final Logger _logger = Logger('AuthService');

  // Dynamically set base URL based on whether the app is running on an emulator or physical device
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/auth'; // For web
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.10.20.5:5000/api/auth'; // Your machine's IP address
    } else {
      return 'http://10.10.20.5:5000/api/auth'; // Emulator
    }
  }

  // ✅ Registration API
  static Future<http.Response> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );
      return response;
    } catch (e) {
      _logger.severe("Error connecting to the server during registration: $e");
      throw Exception("Failed to connect to the server");
    }
  }

  // ✅ Login API with User Data Saving
  static Future<http.Response> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    // Capture the provider instance now, before any await.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveTokens(data['accessToken'], data['refreshToken']);
        _logger.info("✅ Tokens saved successfully");

        // Now use the stored provider instance.
        userProvider.setUserData(
          id: data['user']['id'],
          username: data['user']['username'],
          email: data['user']['email'],
          displayName: data['user']['displayName'],
          profilePicture: data['user']['profilePicture'],
        );
      }

      return response;
    } catch (e) {
      _logger.severe("Login Error: $e");
      throw Exception("Failed to connect to the server during login");
    }
  }

  // ✅ Save Tokens
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    debugPrint("✅ Access Token Saved: $accessToken");
  }

  // ✅ Retrieve Access Token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token != null) {
      _logger.info("🔐 Access token retrieved at ${DateTime.now()}");
    } else {
      _logger.warning("🚫 Access token not found or expired.");
    }

    return token;
  }

  // ✅ Refresh Access Token
  static Future<bool> refreshAccessToken(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    if (refreshToken != null) {
      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('accessToken', data['accessToken']);
        _logger.info("🔄 Access token refreshed successfully");
        return true;
      } else if (response.statusCode == 401) {
        await logout();
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/login');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Session expired. Please log in again.")),
        );
        return false;
      } else {
        throw Exception('Failed to refresh access token');
      }
    }
    return false;
  }

  // ✅ Logout Functionality
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _logger.info("🚪 User logged out and tokens cleared");
  }

  // ✅ Check Authentication Status
  static Future<bool> isAuthenticated(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (accessToken != null) {
      _logger.info("🔐 User is authenticated with a valid access token");
      return true;
    }

    if (refreshToken != null) {
      try {
        // ignore: use_build_context_synchronously
        bool refreshed = await refreshAccessToken(context);
        final newAccessToken = prefs.getString('accessToken');
        return newAccessToken != null && refreshed;
      } catch (e) {
        _logger.warning("⚠️ Token refresh failed: $e");
        return false;
      }
    }

    _logger.warning("🚫 No valid token found, user needs to log in again.");
    return false;
  }

  // ✅ Fetch User Data API
  static Future<void> fetchUserData(BuildContext context) async {
    try {
      final accessToken = await getAccessToken();

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ignore: use_build_context_synchronously
        Provider.of<UserProvider>(context, listen: false).setUserData(
          id: data['user']['id'],
          username: data['user']['username'],
          email: data['user']['email'],
          displayName: data['user']['displayName'],
          profilePicture: data['user']['profilePicture'],
        );
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      _logger.severe("Fetch User Data Error: $e");
    }
  }

  // ✅ Fetch All Users API
  static Future<List<Map<String, String>>> fetchAllUsers(
    BuildContext context,
  ) async {
    try {
      final accessToken = await getAccessToken();

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Map<String, String>> users = [];
        for (var user in data['users']) {
          users.add({
            "id": user['id'],
            "username": user['username'],
            "displayName": user['displayName'],
            "profilePicture": user['profilePicture'],
          });
        }
        return users;
      } else {
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      _logger.severe("Fetch All Users Error: $e");
      return [];
    }
  }
}
