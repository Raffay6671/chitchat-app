import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/group_service.dart'; // ✅ Import group service
import '../../providers/user_provider.dart';
import '../chatscreen/chat_screen.dart';
import '../chatscreen/group_chat_screen.dart'; // ✅ Import group chat screen
import '../../widgets/group_collage_avatar.dart'; // ✅ Group avatar for displaying group users

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allItems = []; // ✅ Holds users + groups
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllUsersAndGroups();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllUsersAndGroups() async {
    setState(() => _isLoading = true);

    try {
      final users = await AuthService.fetchAllUsers(context);
      final groups = await GroupService.fetchGroups();

      // ✅ Merge users & groups into a single list
      final combinedList = [
        ...groups.map(
          (group) => {
            "type": "group",
            "id": group["id"],
            "name": group["name"],
            "members": group["groupUsers"], // Group members list
          },
        ),
        ...users.map(
          (user) => {
            "type": "user",
            "id": user["id"],
            "name": user["username"],
            "profilePicture": user["profilePicture"],
          },
        ),
      ];

      setState(() {
        _allItems = combinedList;
        _filteredItems = combinedList;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching users & groups: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredItems =
          query.isEmpty
              ? _allItems
              : _allItems.where((item) {
                final name = item["name"]?.toLowerCase() ?? "";
                return name.contains(query);
              }).toList();
    });
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    final userId = Provider.of<UserProvider>(context, listen: false).id;
    final isGroup = item["type"] == "group";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading:
            isGroup
                ? GroupCollageAvatar(
                  members: item["members"],
                ) // ✅ Show group collage avatar
                : CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      item["profilePicture"] != null &&
                              item["profilePicture"].isNotEmpty
                          ? NetworkImage(
                            'http://10.10.20.5:5000${item["profilePicture"]}',
                          )
                          : null,
                  child:
                      item["profilePicture"] == null ||
                              item["profilePicture"].isEmpty
                          ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          )
                          : null,
                ),
        title: Text(
          item["name"] ?? "Unknown",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          if (isGroup) {
            _navigateToGroupChat(item["id"], item["name"]);
          } else {
            _navigateToChat(item["id"], item["name"]);
          }
        },
        trailing: IconButton(
          icon: Icon(isGroup ? Icons.group : Icons.chat_bubble_outline),
          color: Colors.blueAccent,
          onPressed: () {
            if (isGroup) {
              _navigateToGroupChat(item["id"], item["name"]);
            } else {
              _navigateToChat(item["id"], item["name"]);
            }
          },
        ),
      ),
    );
  }

  void _navigateToChat(String receiverId, String receiverName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                ChatScreen(receiverId: receiverId, receiverName: receiverName),
      ),
    );
  }

  void _navigateToGroupChat(String groupId, String groupName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupChatScreen(groupId: groupId, groupName: groupName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = _filteredItems.length;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        titleSpacing: 0,
        title: Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
              hintText: "Search People & Groups...",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.black54),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                    child: Text(
                      "People & Groups",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        itemCount == 0
                            ? const Center(
                              child: Text(
                                "No users or groups found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: itemCount,
                              itemBuilder:
                                  (_, index) =>
                                      _buildItemTile(_filteredItems[index]),
                            ),
                  ),
                ],
              ),
    );
  }
}
