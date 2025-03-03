import 'package:flutter/material.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onCamera;
  final VoidCallback onMic;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onCamera,
    required this.onMic,
  });

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
          // 📎 Attachment Icon
          IconButton(icon: const Icon(Icons.attach_file), onPressed: onAttach),

          // ✏️ Message Text Field
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Write your message",
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
            ),
          ),

          // 📷 Camera Icon
          IconButton(icon: const Icon(Icons.camera_alt), onPressed: onCamera),

          // 🎤 Mic Icon
          IconButton(icon: const Icon(Icons.mic), onPressed: onMic),

          // 🚀 **Send Button**
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue), // ✅ Added
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
