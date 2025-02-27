import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../services/socket_service.dart';
import '../../providers/user_provider.dart';

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
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();

    // ✅ Socket connection
    final socketService = Provider.of<SocketService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Connect socket if not already connected
    if (userProvider.id != null) {
      socketService.connect(userProvider.id!);
    }

    // Listen for incoming messages
    socketService.listenForMessages((message) {
      debugPrint('📩 New message received: ${message['message']}');
      setState(() {
        _messages.add(message);
      });
    });

    // (Optional) Fetch chat history
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoadingHistory = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.id == null || widget.receiverId.isEmpty) return;

    final myId = userProvider.id!;
    final theirId = widget.receiverId;

    try {
      final url = Uri.parse('http://10.10.20.5:5000/api/messages/$myId/$theirId');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final List messagesList = data['messages'];
        // Convert to List<Map<String,dynamic>>
        final history = messagesList.map<Map<String, dynamic>>((msg) => {
          'id': msg['id'],
          'senderId': msg['senderId'],
          'receiverId': msg['receiverId'],
          'message': msg['content'],
          'createdAt': msg['createdAt'],
        }).toList();

        setState(() {
          _messages.addAll(history);
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching chat history: $e');
    }

    setState(() => _isLoadingHistory = false);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final messageMap = {
      'senderId': userProvider.id,
      'receiverId': widget.receiverId,
      'message': _messageController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Log & Send
    debugPrint('📩 Sending: ${messageMap['message']} to ${messageMap['receiverId']}');
    Provider.of<SocketService>(context, listen: false).sendMessage(messageMap);

    // Add to local UI
    setState(() {
      _messages.add(messageMap);
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).id ?? '';
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
          if (_isLoadingHistory)
            const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              reverse: true, 
              itemCount: _messages.length,
              itemBuilder: (ctx, i) {
                // Because we reversed the list, get item from the end
                final msg = _messages[_messages.length - 1 - i];
                final isMe = (msg['senderId'] == userId);

                // Format time if needed
                final createdAt = msg['createdAt'] ?? msg['timestamp'] ?? '';

                return _buildChatBubble(
                  isMe: isMe,
                  text: msg['message'],
                  time: createdAt.toString(),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble({required bool isMe, required String text, required String time}) {
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
            Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              time, // Or format with intl package
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

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey[200],
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type a message...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
