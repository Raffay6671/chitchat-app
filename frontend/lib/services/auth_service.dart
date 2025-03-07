import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../src/providers/user_provider.dart'; // ✅ Import UserProvider for state management
import 'package:flutter/foundation.dart'; // For checking if the app is running on physical device or emulator
import '../config.dart';

class AuthService {
  // Dynamically set base URL based on whether the app is running on an emulator or physical device
  static String get baseUrl {
    if (kIsWeb) {
      return '${AppConfig.serverIp}/api/auth'; // For web
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return '${AppConfig.serverIp}/api/auth'; // Your machine's IP address
    } else {
      return '${AppConfig.serverIp}/api/auth'; // Emulator
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
      print("Error connecting to the server during registration: $e");
      throw Exception("Failed to connect to the server");
    }
  }

  static Future<http.Response> loginUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      final url = Uri.parse('$baseUrl/login');
      print("🔄 Sending login request to: $url");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save the tokens and userId in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data['user']['id'] ?? '');
        await saveTokens(data['accessToken'] ?? '', data['refreshToken'] ?? '');

        print("✅ Tokens saved successfully");

        // Handle potential null values in user data
        userProvider.setUserData(
          id: data['user']['id'] ?? '', // Default to empty string if null
          username: data['user']['username'] ?? '',
          email: data['user']['email'] ?? '',
          displayName: data['user']['displayName'] ?? 'User', // Default value
          profilePicture: data['user']['profilePicture'] ?? '', // Default value
        );

        print("✅ User data saved successfully");

        // Fetch user data (including profile picture)
        await fetchUserData(context);
      }

      return response;
    } catch (e) {
      print("❌ Login Error: $e");
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
    print("✅ Access Token Saved: $accessToken");
  }

  // ✅ Retrieve Access Token

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      print("🚫 Access token not found.");
      return null;
    }

    String base64UrlFix(String input) {
      while (input.length % 4 != 0) {
        input += "="; // Add padding
      }
      return input;
    }

    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64UrlFix(token.split(".")[1]))),
    );

    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);

    if (expiry.isBefore(DateTime.now())) {
      print("🚫 Access token expired. Attempting to refresh.");
      return null; // Return null so refresh can be triggered externally
    }

    print("🔐 Access token is valid.");
    return token;
  }

  // Update in refreshAccessToken function
  static Future<String?> refreshAccessToken() async {
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
        await prefs.setString(
          'accessToken',
          data['accessToken'],
        ); // Update the new access token
        print("🔄 Access token refreshed successfully");
        return data['accessToken']; // Return new access token
      } else if (response.statusCode == 401) {
        // Refresh token expired or invalid
        await logout(); // Log out user if refresh token fails
        print("⚠️ Refresh token expired or invalid.");
        return null;
      } else {
        print('Failed to refresh access token');
        throw Exception('Failed to refresh access token');
      }
    }
    return null;
  }

  // ✅ Logout Functionality
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final userId = prefs.getString('userId'); // Retrieve userId from prefs
    print("*****************************************$userId");

    if (accessToken != null && userId != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer $accessToken', // Send the access token for validation
          },
          body: jsonEncode({"userId": userId}), // Send the userId to the server
        );

        if (response.statusCode == 200) {
          print("🚪 User logged out and tokens cleared");
        } else {
          print("⚠️ Failed to logout from server: ${response.body}");
        }
      } catch (e) {
        print("⚠️ Logout request failed, clearing tokens locally.");
      }
    }

    await prefs
        .clear(); // Clear all prefs, including access token, refresh token, and userId
    print("🚪 Tokens cleared from SharedPreferences");
  }

  // ✅ Check Authentication Status
  static Future<bool> isAuthenticated(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');

    if (accessToken != null) {
      print("🔐 User is authenticated with a valid access token");
      return true;
    }

    if (refreshToken != null) {
      try {
        // ignore: use_build_context_synchronously
        String? newAccessToken = await refreshAccessToken();
        bool refreshed = newAccessToken != null; // ✅ Fix: Convert to bool
        return refreshed;
      } catch (e) {
        print("⚠️ Token refresh failed: $e");
        return false;
      }
    }

    print("🚫 No valid token found, user needs to log in again.");
    return false;
  }

  // ✅ Fetch User Data API
  static Future<void> fetchUserData(BuildContext context) async {
    try {
      String? accessToken = await getAccessToken();

      if (accessToken == null) {
        print("⚠️ Access token is missing, trying refresh.");
        accessToken = await refreshAccessToken();

        if (accessToken == null) {
          // If refresh also fails, show an error and log out
          print("❌ Token refresh failed. Logging out.");
          await logout(); // Log out the user
          return;
        }
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Provider.of<UserProvider>(context, listen: false).setUserData(
          id: data['user']['id'],
          username: data['user']['username'],
          email: data['user']['email'],
          displayName: data['user']['displayName'],
          profilePicture: data['user']['profilePicture'],
        );
      } else if (response.statusCode == 401) {
        print("⚠️ Access token expired, refreshing...");
        accessToken = await refreshAccessToken();

        if (accessToken != null) {
          return fetchUserData(context); // Retry with new token
        } else {
          throw Exception('Failed to refresh access token');
        }
      } else {
        print("Error fetching user data: ${response.body}");
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      print("Fetch User Data Error: $e");
    }
  }

  // ✅ Fetch All Users API
  static Future<List<Map<String, String>>> fetchAllUsers(
    BuildContext context,
  ) async {
    try {
      String? accessToken = await getAccessToken();

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
        print("Error fetching users: ${response.body}");
        throw Exception('Failed to fetch users');
      }
    } catch (e) {
      print("Fetch All Users Error: $e");
      return [];
    }
  }
}
