import 'dart:convert';
import 'dart:io'; // ✅ Import for File class
import 'package:path/path.dart'; // ✅ Import for basename function
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MediaService {
  static const String _baseUrl = "http://10.10.20.5:5000"; // Your backend URL

  // ✅ Create a message first and return its ID
  static Future<String?> createMessage(
    String senderId,
    String receiverId,
  ) async {
    final url = Uri.parse("$_baseUrl/api/messages/create");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "senderId": senderId,
        "receiverId": receiverId,
        "messageType": "image",
        "content": "",
      }),
    );

    if (res.statusCode == 201) {
      final data = json.decode(res.body);
      return data['messageId'];
    } else {
      debugPrint("❌ Failed to create message: ${res.body}");
      return null;
    }
  }

  // ✅ Upload Media after message creation
  static Future<String?> uploadMedia(
    File file,
    String userId,
    String messageId,
    String mediaType,
  ) async {
    try {
      var uri = Uri.parse("$_baseUrl/api/media/upload");
      var request = http.MultipartRequest("POST", uri);

      // ✅ Add file
      var multipartFile = await http.MultipartFile.fromPath(
        "file",
        file.path,
        filename: basename(file.path), // ✅ Now basename() will work
      );
      request.files.add(multipartFile);

      // ✅ Add metadata
      request.fields["userId"] = userId;
      request.fields["messageId"] = messageId;
      request.fields["mediaType"] = mediaType;

      // ✅ Set headers
      request.headers.addAll({"Content-Type": "multipart/form-data"});

      // ✅ Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['mediaUrl'];
      } else {
        debugPrint("❌ Upload Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error uploading media: $e");
      return null;
    }
  }
}
