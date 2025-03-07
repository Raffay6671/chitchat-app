import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../services/socket_service.dart';
import '../../providers/user_provider.dart';
import '../../providers/message_provider.dart';
import '../../widgets/message_input.dart'; // ✅ Added Import
import '../../../config.dart';
import '../../widgets/p2p_messagebubble.dart';
import '../../widgets/profile_avatar.dart';

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
        '${AppConfig.serverIp}/api/messages/$myId/$theirId',
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
                'senderProfilePic':
                    msg['senderProfilePic'] ?? '', // ✅ Add sender profile
                'receiverProfilePic':
                    msg['receiverProfilePic'] ?? '', // ✅ Add receiver profile
                'content': msg['content'],
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
      'senderId':
          userProvider.id ?? "unknown_sender", // ✅ Provide default value
      'receiverId':
          widget.receiverId ?? "unknown_receiver", // ✅ Provide default value
      'content':
          _messageController.text.isNotEmpty
              ? _messageController.text
              : "[Empty Message]", // ✅ Avoid null messages
      'timestamp': DateTime.now().toIso8601String(),
      'messageType':
          _messageController.text.contains("/uploads/media/")
              ? "image"
              : "text",
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
    final socketService = Provider.of<SocketService>(context);
    final isOnline = socketService.isUserOnline(widget.receiverId);

    print("Receiver Profile Image***** URL: ${widget.receiverProfileImage}");

    final userId = Provider.of<UserProvider>(context).id ?? '';
    final messages = Provider.of<MessageProvider>(context).messages;
    print("Receiver Profile Image URL: ${widget.receiverProfileImage}");

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white

      appBar: AppBar(
        backgroundColor: Colors.white, // Set background color to white
        elevation: 0, // Removes the shadow to match the background seamlessly
        scrolledUnderElevation: 0, // Ensures no shadow appears when scrolled
        title: Row(
          children: [
            if (widget.receiverProfileImage != null)
              ProfileAvatar(
                imageUrl: widget.receiverProfileImage!,
                size: 18,
                isOnline: isOnline,
              ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.0,
                    letterSpacing: 0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline ? "Active Now" : "Offline Now",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.0,
                    letterSpacing: 0,
                    color: isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 1.0),
            child: IconButton(
              icon: ImageIcon(
                AssetImage('assets/icons/call.png'), // Path to call icon
                color: Colors.black,
              ),
              iconSize: 30, // Set icon size
              onPressed: () {
                // Handle call action
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: ImageIcon(
                AssetImage('assets/icons/Video.png'), // Path to video icon
                color: Colors.black,
              ),
              iconSize: 40, // Increase the icon size to scale it
              onPressed: () {
                // Handle video call action
              },
            ),
          ),
        ],
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
                final messageContent = msg['content'] ?? '[Empty]';

                return P2PMessageBubble(
                  senderName: isMe ? 'You' : widget.receiverName,
                  senderProfilePic:
                      isMe
                          ? (Provider.of<UserProvider>(
                                context,
                              ).profilePicture ??
                              '')
                          : msg['receiverProfilePic'] ??
                              widget.receiverProfileImage ??
                              '',
                  message: messageContent,
                  timestamp: createdAt,
                  isMe: isMe,
                );
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
}
