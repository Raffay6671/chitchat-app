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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // 📎 Attachment Icon (File Picker)
          IconButton(
            icon: const Icon(Icons.attach_file),
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
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              enabled: !_isUploading, // Disable input while uploading
            ),
          ),

          // 📷 Camera Icon
          IconButton(
            icon: const Icon(Icons.camera_alt),
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
