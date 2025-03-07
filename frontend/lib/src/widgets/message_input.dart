import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/media_service.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String userId; // ✅ Sender's User ID
  final String receiverId; // ✅ Receiver's User ID (needed to create a message)

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.userId,
    required this.receiverId,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  File? _selectedImage;
  bool _isUploading = false;

  // ✅ Function to pick an image from Camera or File Picker
  Future<void> _pickImage({bool fromCamera = false}) async {
    File? selectedFile;

    if (fromCamera) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile == null) return;
      selectedFile = File(pickedFile.path);
    } else {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) return;
      selectedFile = File(result.files.single.path!);
    }

    setState(() {
      _selectedImage = selectedFile;
      _isUploading = true; // Show loading indicator
    });

    // ✅ 1️⃣ Create a message record first to get a valid messageId
    final messageId = await MediaService.createMessage(
      widget.userId,
      widget.receiverId,
    );

    if (messageId == null) {
      debugPrint("❌ Failed to create message. Cannot upload image.");
      setState(() => _isUploading = false);
      return;
    }

    // ✅ 2️⃣ Now, upload the selected image with the valid messageId
    final mediaUrl = await MediaService.uploadMedia(
      _selectedImage!,
      widget.userId,
      messageId, // ✅ Use the generated messageId
      "image",
    );

    setState(() => _isUploading = false);

    if (mediaUrl != null) {
      debugPrint("✅ Image uploaded successfully: $mediaUrl");
      widget.controller.text = mediaUrl; // ✅ Send URL as a message
      widget.onSend(); // ✅ Trigger the send function
    } else {
      debugPrint("❌ Image upload failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // ✅ Takes full screen width
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.zero, // ✅ No rounded corners anywhere
      ),
      child: Row(
        children: [
          // 📎 Attachment Icon (File Picker)
          // 📎 Attachment Icon (File Picker)
          IconButton(
            icon: Image.asset(
              "assets/images/attachment.png", // ✅ Load the custom attachment icon
              width: 24, // Adjust size if needed
              height: 24,
            ),
            onPressed: () => _pickImage(fromCamera: false),
          ),

          // ✏️ Message Text Field
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText:
                    _isUploading ? "Uploading..." : "Write your message...",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                filled: true,
                fillColor: const Color(
                  0xFFF2F7FB,
                ), // ✅ Background color applied
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, // Adjusted for balance
                  vertical: 8, // Reduced height
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // ✅ Rounded corners
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // ✅ Rounded corners
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(
                    12,
                  ), // Adjust for proper alignment
                  child: Image.asset(
                    "assets/images/notworking.png",
                    width: 20,
                    height: 10,
                  ),
                ),
              ),

              enabled: !_isUploading, // Disable input while uploading
            ),
          ),

          // 📷 Camera Icon
          // Replace the Camera Icon with an Image from assets
          IconButton(
            icon: Image.asset(
              "assets/images/camera.png", // Replace with the actual path of your image
              width: 24, // Adjust size as needed
              height: 24, // Adjust size as needed
            ),
            onPressed: () => _pickImage(fromCamera: true),
          ),

          IconButton(
            icon: Image.asset(
              "assets/images/microphone.png", // Replace with the actual path of your image
              width: 24, // Adjust size as needed
              height: 24, // Adjust size as needed
            ),
            onPressed: () => _pickImage(fromCamera: true),
          ),

          // ✉️ Send Button
          IconButton(
            icon:
                _isUploading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send, color: Colors.blueAccent),
            onPressed:
                _isUploading ? null : widget.onSend, // Disable if uploading
          ),
        ],
      ),
    );
  }
}
