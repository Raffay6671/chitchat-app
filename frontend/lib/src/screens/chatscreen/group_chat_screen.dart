import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/socket_service.dart';
import '../../providers/group_message_provider.dart';
import '../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/group_message_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ensure this user joins the group room
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.joinGroup(widget.groupId);
    _fetchGroupHistory();
    _setupSocketListeners();
  }

  Future<void> _fetchGroupHistory() async {
    setState(() => _isLoading = true);

    final groupMessageProvider = Provider.of<GroupMessageProvider>(
      context,
      listen: false,
    );

    try {
      final token = await AuthService.getAccessToken(); // ✅ Fetch token
      if (token == null) {
        debugPrint("🚨 ERROR: Access token is missing!");
        return;
      }

      final url = Uri.parse(
        'http://10.10.20.5:5000/api/groups/${widget.groupId}/messages',
      );

      final res = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // ✅ Ensure token is included
        },
      );

      debugPrint('Heavy System Response: ${res.body}');

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final List messagesList = data['messages'];

        final history =
            messagesList.map<Map<String, dynamic>>((msg) {
              return {
                'id': msg['id'],
                'senderId': msg['senderId'],
                'senderName':
                    msg['senderName'] ??
                    "Unknown", // ✅ Ensure sender name is stored
                'senderProfilePic':
                    msg['senderProfilePic'] ??
                    "", // ✅ Ensure profile pic is stored
                'groupId': msg['groupId'],
                'content': msg['content'],
                'createdAt':
                    msg['createdAt'] ??
                    "Unknown time", // ✅ Prevent null timestamps
              };
            }).toList();

        groupMessageProvider.setMessages(widget.groupId, history);
        debugPrint("✅ Group chat history loaded: ${history.length} messages");
      } else {
        debugPrint("❌ Failed to fetch group chat history: ${res.body}");
      }
    } catch (e) {
      debugPrint('❌ Error fetching group chat history: $e');
    }

    setState(() => _isLoading = false);
  }

  void _setupSocketListeners() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    final groupMessageProvider = Provider.of<GroupMessageProvider>(
      context,
      listen: false,
    );

    // ✅ Remove old listener to prevent duplication
    socketService.removeGroupListeners();

    // ✅ Listen for new messages
    socketService.listenForGroupMessages((data) {
      if (data['groupId'] == widget.groupId) {
        debugPrint('📩 Received WebSocket message: ${data['content']}');

        // ✅ Add the message and trigger UI update
        groupMessageProvider.addMessage(widget.groupId, data);

        // ✅ Ensure UI updates immediately
        if (mounted) {
          setState(() {}); // ✅ Force UI rebuild
        }
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);

    if (userProvider.id == null) {
      debugPrint('❌ User ID is null. Cannot send group message.');
      return;
    }

    final messageMap = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'senderId': userProvider.id,
      'groupId': widget.groupId,
      'content': _messageController.text,
      // ❌ Do NOT add 'createdAt' here! The backend should set it
    };

    // ✅ Send only via WebSocket, do NOT add message locally
    socketService.sendGroupMessage(widget.groupId, messageMap);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final groupMessages = Provider.of<GroupMessageProvider>(
      context,
    ).getMessages(widget.groupId);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.groupName),
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),

            // ✅ Display chat messages
            Expanded(
              child:
                  groupMessages.isEmpty
                      ? const Center(child: Text("No messages yet."))
                      : ListView.builder(
                        reverse: true,
                        itemCount: groupMessages.length,
                        itemBuilder: (ctx, i) {
                          final message =
                              groupMessages[groupMessages.length - 1 - i];
                          final isMe =
                              message['senderId'] ==
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).id;

                          return GroupMessageBubble(
                            senderName:
                                message['senderName'], // ✅ Ensure senderName is passed
                            senderProfilePic:
                                message['senderProfilePic'], // ✅ Ensure profilePic is passed
                            message: message['content'],
                            timestamp: message['createdAt'],
                            isMe: isMe,
                          );
                        },
                      ),
            ),

            // ✅ Input field for sending messages
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // ✅ Message input field
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration.collapsed(
                hintText: "Type a message...",
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
