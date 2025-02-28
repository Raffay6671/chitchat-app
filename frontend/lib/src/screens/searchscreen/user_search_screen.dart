import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../chatscreen/chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allUsers = [];
  List<Map<String, String>> _filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllUsers() async {
    setState(() => _isLoading = true);
    final users = await AuthService.fetchAllUsers(context);
    setState(() {
      _allUsers = users;
      _filteredUsers = users;
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredUsers = query.isEmpty
          ? _allUsers
          : _allUsers
              .where((user) => (user["username"]?.toLowerCase() ?? "").contains(query))
              .toList();
    });
  }

  Widget _buildUserTile(Map<String, String> user) {
    final userId = Provider.of<UserProvider>(context, listen: false).id;
    final receiverId = user["id"] ?? "";
    if (receiverId == userId) return const SizedBox.shrink();

    final username = user["username"] ?? "Unknown User";
    final profilePicture = user["profilePicture"];

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          backgroundImage: (profilePicture != null && profilePicture.isNotEmpty)
              ? NetworkImage('http://10.10.20.5:5000$profilePicture')
              : null,
          child: (profilePicture == null || profilePicture.isEmpty)
              ? const Icon(Icons.person, color: Colors.white, size: 30)
              : null,
        ),
        title: Text(
          username,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        onTap: () => _navigateToChat(receiverId, username),
        trailing: IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          color: Colors.blueAccent,
          onPressed: () => _navigateToChat(receiverId, username),
        ),
      ),
    );
  }

  void _navigateToChat(String receiverId, String receiverName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: receiverId,
          receiverName: receiverName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userCount = _filteredUsers.length;

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
              hintText: "Search People...",
              hintStyle: TextStyle(color: Colors.black45),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.black54),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                  child: Text(
                    "People",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: userCount == 0
                      ? const Center(
                          child: Text(
                            "No users found",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: userCount,
                          itemBuilder: (_, index) => _buildUserTile(_filteredUsers[index]),
                        ),
                ),
              ],
            ),
    );
  }
}
