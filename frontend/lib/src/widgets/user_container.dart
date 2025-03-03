import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/chatscreen/chat_screen.dart';
import '../screens/chatscreen/group_chat_screen.dart';
import '../widgets/group_collage_avatar.dart';
import '../../../services/group_service.dart';
import '../../../services/socket_service.dart';

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

    _refreshGroups(); // ✅ Initial Fetch

    // ✅ Listen for online/offline events
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket?.on('userOnline', (data) {
      setState(() {
        onlineUsers[data['userId']] = true;
      });
    });

    socketService.socket?.on('userOffline', (data) {
      setState(() {
        onlineUsers[data['userId']] = false;
      });
    });

    // ✅ Request current online users when the screen loads
    socketService.socket?.emit('getOnlineUsers');
    socketService.socket?.on('onlineUsers', (data) {
      setState(() {
        onlineUsers = Map.fromIterable(
          data,
          key: (userId) => userId,
          value: (_) => true,
        );
      });
    });
  }

  void _refreshGroups() {
    setState(() {
      _futureGroups = GroupService.fetchGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.id;

    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: RefreshIndicator(
          // ✅ Pull-down to refresh
          onRefresh: () async {
            _refreshGroups();
          },
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _futureGroups, // ✅ Fetch groups dynamically
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error loading groups"));
              }
              final groups = snapshot.data ?? [];

              // ✅ Merge users and groups dynamically
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
                    .where(
                      (user) => user["id"] != userId,
                    ) // Exclude current user
                    .map(
                      (user) => {
                        "type": "user",
                        "id": user["id"],
                        "name": user["username"],
                        "profilePicture": user["profilePicture"],
                      },
                    ),
              ];

              return ListView.separated(
                itemCount: combinedList.length,
                separatorBuilder:
                    (context, index) =>
                        const Divider(thickness: 0.3, color: Colors.grey),
                itemBuilder: (context, index) {
                  final item = combinedList[index];

                  return GestureDetector(
                    onTap: () {
                      if (item["type"] == "group") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => GroupChatScreen(
                                  groupId: item["id"],
                                  groupName: item["name"],
                                ),
                          ),
                        ).then(
                          (_) =>
                              _refreshGroups(), // ✅ Refresh when returning from GroupChatScreen
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatScreen(
                                  receiverId: item["id"],
                                  receiverName: item["name"],
                                ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // ✅ Show group collage if it's a group, else show user profile picture
                          item["type"] == "group"
                              ? GroupCollageAvatar(members: item["members"])
                              : Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage:
                                        item["profilePicture"] != null &&
                                                item["profilePicture"]
                                                    .isNotEmpty
                                            ? NetworkImage(
                                              'http://10.10.20.5:5000${item["profilePicture"]}',
                                            )
                                            : null,
                                    child:
                                        item["profilePicture"] == null ||
                                                item["profilePicture"].isEmpty
                                            ? const Icon(
                                              Icons.person,
                                              size: 30,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),

                                  // ✅ Small status indicator (bottom-right)
                                  Positioned(
                                    bottom: 2, // Adjust position
                                    right: 2,
                                    child: Container(
                                      width: 12, // Tiny circle size
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color:
                                            onlineUsers[item["id"]] == true
                                                ? Colors.green
                                                : Colors
                                                    .grey, // Green if online, Grey if offline
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ), // White border for visibility
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                          const SizedBox(width: 15),

                          // ✅ Display name (group or user)
                          Expanded(
                            child: Text(
                              item["name"] ?? "Unknown",
                              style: const TextStyle(
                                color: Color(0xFF000E08),
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
