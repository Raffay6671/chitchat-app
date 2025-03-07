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
import '../../../config.dart';

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
  int totalMembers = 0; // Store total members count
  int onlineMembers = 0; // Store online members count

  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.joinGroup(widget.groupId);

    // Pass `mounted` to the fetchGroupMembers method
    socketService.fetchGroupMembers(widget.groupId, (total, online) {
      if (mounted) {
        setState(() {
          totalMembers = total;
          onlineMembers = online;
        });
      }
    }, mounted); // Pass mounted here

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
        '${AppConfig.serverIp}/api/groups/${widget.groupId}/messages',
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
    // title: Text(widget.groupName),

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Set background color to white

        appBar: AppBar(
          backgroundColor: Colors.white, // Set AppBar background color to white
          elevation: 0, // Remove shadow
          scrolledUnderElevation: 0, // Prevent shadow on scroll
          leading: Padding(
            padding: const EdgeInsets.only(left: 2.0), // Adjust padding
            child: IconButton(
              icon: Image.asset(
                'assets/icons/leftNav.png', // Custom left arrow
                height: 24,
                width: 15,
              ),
              onPressed: () {
                Navigator.pop(context); // Go back
              },
            ),
          ),
          title: Row(
            children: [
              // ✅ Group Icon
              CircleAvatar(
                backgroundImage: AssetImage('assets/icons/group.png'),
                radius: 22,
              ),
              const SizedBox(width: 8), // Space between icon and name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Group Name
                    Text(
                      widget.groupName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis, // Prevents overflow
                    ),
                    const SizedBox(height: 4),
                    // ✅ Dynamic Members Count
                    Text(
                      "$totalMembers members, $onlineMembers online",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        height: 1.0,
                        letterSpacing: 0,
                        color: Color.fromARGB(
                          211,
                          114,
                          126,
                          122,
                        ), // Light grey color
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 1.0),
              child: IconButton(
                icon: ImageIcon(
                  AssetImage('assets/icons/call.png'),
                  color: Colors.black,
                ),
                iconSize: 30,
                onPressed: () {
                  // Handle call action
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: IconButton(
                icon: ImageIcon(
                  AssetImage('assets/icons/Video.png'),
                  color: Colors.black,
                ),
                iconSize: 40,
                onPressed: () {
                  // Handle video call action
                },
              ),
            ),
          ],
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
