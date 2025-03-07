import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/chatscreen/chat_screen.dart';
import '../screens/chatscreen/group_chat_screen.dart';
import '../widgets/group_collage_avatar.dart';
import '../../../services/group_service.dart';
import '../../../services/socket_service.dart';
import '../../config.dart';

class UserContainer extends StatefulWidget {
  final List<Map<String, String>> users;

  const UserContainer({super.key, required this.users});

  @override
  _UserContainerState createState() => _UserContainerState();
}

class _UserContainerState extends State<UserContainer> {
  late Future<List<Map<String, dynamic>>> _futureGroups;
  Map<String, bool> onlineUsers = {}; // Track online users

  @override
  void initState() {
    super.initState();

    _refreshGroups(); // Initial Fetch

    // Listen for online/offline events
    final socketService = Provider.of<SocketService>(context, listen: false);

    // Debug the initial state of last messages
    print("Initial last messages state: ${socketService.lastMessages}");
    print("Initial unread count state: ${socketService.unreadMessageCount}");

    socketService.socket?.on('userOnline', (data) {
      print("User ${data['userId']} is online");
      setState(() {
        onlineUsers[data['userId']] = true;
      });
    });

    socketService.socket?.on('userOffline', (data) {
      print("User ${data['userId']} is offline");
      setState(() {
        onlineUsers[data['userId']] = false;
      });
    });

    // Request current online users when the screen loads
    socketService.socket?.emit('getOnlineUsers');
    socketService.socket?.on('onlineUsers', (data) {
      setState(() {
        // Initially mark all users as offline
        onlineUsers = Map.fromIterable(
          widget.users, // List of all users
          key: (user) => user["id"], // user id as the key
          value: (_) => false, // Default all users as offline
        );

        // Then mark online users as true
        for (var userId in data) {
          onlineUsers[userId] = true;
        }
      });
    });

    // Listen for changes in the SocketService state
    socketService.addListener(_onSocketServiceUpdated);
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    Provider.of<SocketService>(
      context,
      listen: false,
    ).removeListener(_onSocketServiceUpdated);
    super.dispose();
  }

  // This will be called whenever SocketService notifies listeners
  void _onSocketServiceUpdated() {
    if (mounted) {
      setState(() {
        // Just trigger a rebuild
      });
    }
  }

  void _refreshGroups() {
    setState(() {
      _futureGroups = GroupService.fetchGroups();
    });
  }

  // Add this method to your _UserContainerState class
  String getChatId(String user1, String user2) {
    // Sort the IDs to ensure consistency regardless of who is sender/receiver
    final sortedIds = [user1, user2]..sort();
    return "${sortedIds[0]}_${sortedIds[1]}";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.id;

    // Access socketService with listen: true to rebuild when it changes
    final socketService = Provider.of<SocketService>(context, listen: true);

    // Debug current data
    print(
      "Building UserContainer with last messages: ${socketService.lastMessages}",
    );
    print(
      "Building UserContainer with unread counts: ${socketService.unreadMessageCount}",
    );

    return Expanded(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(70),
                topRight: Radius.circular(70),
              ),
            ),
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshGroups();
                // Debug data after refresh
                socketService.debugPrintAllData();
              },
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureGroups,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error loading groups: ${snapshot.error}"),
                    );
                  }
                  final groups = snapshot.data ?? [];

                  final List<Map<String, dynamic>> combinedList = [
                    ...groups.map(
                      (group) => {
                        "type": "group",
                        "id": group["id"],
                        "name": group["name"],
                        "members": group["groupUsers"],
                      },
                    ),
                    ...widget.users
                        .where((user) => user["id"] != userId)
                        .map(
                          (user) => {
                            "type": "user",
                            "id": user["id"],
                            "name": user["username"],
                            "profilePicture": user["profilePicture"],
                          },
                        ),
                  ];
                  return ListView.builder(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: combinedList.length,
                    itemBuilder: (context, index) {
                      final item = combinedList[index];
                      final itemId = item["id"];
                      final currentUserId = userProvider.id;

                      // Determine the correct ID to use for data lookup
                      String lookupId;
                      if (item["type"] == "group") {
                        // For groups, use the group ID directly
                        lookupId = itemId;
                      } else {
                        // For P2P chats, create a consistent chat ID
                        lookupId = getChatId(currentUserId!, itemId);
                      }

                      // Get last message and unread count
                      final lastMessageData =
                          socketService.lastMessages[lookupId] ??
                          socketService
                              .lastMessages[itemId]; // Fallback for backward compatibility

                      final unreadCount =
                          socketService.unreadMessageCount[lookupId] ??
                          socketService.unreadMessageCount[itemId] ??
                          0; // Fallback with default

                      print(
                        "Item $itemId (LookupId: $lookupId) - Last message: $lastMessageData, Unread: $unreadCount",
                      );

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Reset unread count for this chat or group when it is opened
                              if (item["type"] == "group") {
                                socketService.resetUnreadCount(itemId);
                              } else {
                                // Reset using both the chat ID and the direct ID for P2P chats
                                socketService.resetUnreadCount(lookupId);
                                socketService.resetUnreadCount(
                                  itemId,
                                ); // For backward compatibility
                              }

                              if (item["type"] == "group") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => GroupChatScreen(
                                          groupId: itemId,
                                          groupName: item["name"],
                                        ),
                                  ),
                                ).then((_) => _refreshGroups());
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => ChatScreen(
                                          receiverId: itemId,
                                          receiverName: item["name"],
                                          receiverProfileImage:
                                              item["profilePicture"],
                                        ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Avatar and Status logic
                                  ClipOval(
                                    child:
                                        item["type"] == "group"
                                            ? GroupCollageAvatar(
                                              members: item["members"],
                                            )
                                            : Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                CircleAvatar(
                                                  radius: 24,
                                                  backgroundColor:
                                                      Colors.grey[300],
                                                  backgroundImage:
                                                      item["profilePicture"] !=
                                                                  null &&
                                                              item["profilePicture"]
                                                                  .isNotEmpty
                                                          ? NetworkImage(
                                                            '${AppConfig.serverIp}${item["profilePicture"]}',
                                                          )
                                                          : null,
                                                  child:
                                                      item["profilePicture"] ==
                                                                  null ||
                                                              item["profilePicture"]
                                                                  .isEmpty
                                                          ? const Icon(
                                                            Icons.person,
                                                            size: 24,
                                                            color: Colors.white,
                                                          )
                                                          : null,
                                                ),
                                                // Status indicator
                                                Positioned(
                                                  bottom: 7,
                                                  right: 4,
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          onlineUsers[itemId] ??
                                                                  false
                                                              ? Colors.green
                                                              : Colors.grey,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Display user/group name
                                        Text(
                                          item["name"] ?? "Unknown",
                                          style: const TextStyle(
                                            color: Color(0xFF000E08),
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                          ),
                                        ),

                                        // Unread message + Unread Count Badge horizontally aligned
                                        if (lastMessageData != null &&
                                            lastMessageData['message'] != null)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Display unread message text if available
                                              Expanded(
                                                child:
                                                    lastMessageData != null &&
                                                            lastMessageData['message'] !=
                                                                null
                                                        ? Text(
                                                          lastMessageData['message'],
                                                          style: const TextStyle(
                                                            color: Color(
                                                              0x797C7B80,
                                                            ), // Background color as per Figma
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                          maxLines: 1,
                                                        )
                                                        : const SizedBox.shrink(), // No message to show
                                              ),
                                              // Unread message count badge
                                              if (unreadCount > 0)
                                                Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Color(
                                                          0xFFF04A4C,
                                                        ), // Red color for badge
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: Center(
                                                    child: Text(
                                                      "$unreadCount",
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
