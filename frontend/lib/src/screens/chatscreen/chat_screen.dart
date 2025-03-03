import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../services/socket_service.dart';
import '../../providers/user_provider.dart';
import '../../providers/message_provider.dart';
import '../../widgets/message_input.dart'; // ✅ Added Import

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? receiverProfileImage;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.receiverProfileImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // Only fetch old messages
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );

    if (userProvider.id == null || widget.receiverId.isEmpty) {
      setState(() => _isLoadingHistory = false);
      return;
    }

    final myId = userProvider.id!;
    final theirId = widget.receiverId;

    try {
      final url = Uri.parse(
        'http://10.10.20.5:5000/api/messages/$myId/$theirId',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final List messagesList = data['messages'];

        final history =
            messagesList.map<Map<String, dynamic>>((msg) {
              return {
                'id': msg['id'],
                'senderId': msg['senderId'],
                'receiverId': msg['receiverId'],
                'message': msg['content'],
                'createdAt': msg['createdAt'],
              };
            }).toList();

        messageProvider.setMessages(history);
      } else {
        debugPrint('❌ Error fetching messages: ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching chat history: $e');
    }

    setState(() => _isLoadingHistory = false);
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(
      context,
      listen: false,
    );

    final messageMap = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': userProvider.id,
      'receiverId': widget.receiverId,
      'message': _messageController.text, // ✅ Send image URL if available
      'timestamp': DateTime.now().toIso8601String(),
      'messageType':
          _messageController.text.contains("/uploads/media/")
              ? "image"
              : "text", // ✅ Detect if it's an image
    };

    // Add to provider
    messageProvider.addMessage(messageMap);

    // Send to server
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.sendMessage(messageMap);

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).id ?? '';
    final messages = Provider.of<MessageProvider>(context).messages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.receiverProfileImage != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.receiverProfileImage!),
                radius: 18,
              ),
            const SizedBox(width: 8),
            Text(widget.receiverName),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoadingHistory) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (ctx, i) {
                final msg = messages[messages.length - 1 - i];
                final isMe = (msg['senderId'] == userId);
                final createdAt = msg['createdAt'] ?? msg['timestamp'] ?? '';

                return _buildChatBubble(isMe, msg['message'], createdAt);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MessageInput(
              controller: _messageController,
              onSend: _sendMessage,
              userId: userId, // ✅ Pass userId
              receiverId:
                  widget
                      .receiverId, // ✅ Pass the receiverId (who is being messaged)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isMe, String content, String time) {
    bool isImage =
        content.startsWith("/uploads/media/") ||
        content.endsWith(".jpg") ||
        content.endsWith(".png");

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            isImage
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    "http://10.10.20.5:5000$content", // ✅ Append backend URL
                    width: 200, // ✅ Set image size
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder:
                        (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                  ),
                )
                : Text(
                  content,
                  style: TextStyle(color: isMe ? Colors.white : Colors.black),
                ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
