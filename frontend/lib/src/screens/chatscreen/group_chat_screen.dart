import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/socket_service.dart';
import '../../providers/group_message_provider.dart';
import '../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/group_message_bubble.dart';
import '../../widgets/message_input.dart'; // ✅ Added Import

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
      final token = await AuthService.getAccessToken();
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
          "Authorization": "Bearer $token",
        },
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final List messagesList = data['messages'];

        final history =
            messagesList.map<Map<String, dynamic>>((msg) {
              return {
                'id': msg['id'],
                'senderId': msg['senderId'],
                'senderName': msg['senderName'] ?? "Unknown",
                'senderProfilePic': msg['senderProfilePic'] ?? "",
                'groupId': msg['groupId'],
                'content': msg['content'],
                'createdAt': msg['createdAt'] ?? "Unknown time",
              };
            }).toList();

        groupMessageProvider.setMessages(widget.groupId, history);
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

    socketService.removeGroupListeners();

    socketService.listenForGroupMessages((data) {
      if (data['groupId'] == widget.groupId) {
        groupMessageProvider.addMessage(widget.groupId, data);

        if (mounted) {
          setState(() {});
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
    };

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
                            senderName: message['senderName'],
                            senderProfilePic: message['senderProfilePic'],
                            message: message['content'],
                            timestamp: message['createdAt'],
                            isMe: isMe,
                          );
                        },
                      ),
            ),

            // ✅ Message Input with Send Button
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MessageInput(
                controller: _messageController,
                onSend: _sendMessage,
                userId: Provider.of<UserProvider>(context, listen: false).id!,
                receiverId: widget.groupId, // ✅ Pass groupId instead
              ),
            ),
          ],
        ),
      ),
    );
  }
}
