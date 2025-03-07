import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/group_service.dart'; // ✅ Import group service
import '../chatscreen/chat_screen.dart';
import '../chatscreen/group_chat_screen.dart'; // ✅ Import group chat screen
import '../../widgets/group_collage_avatar.dart'; // ✅ Group avatar for displaying group users
import '../../../config.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:flutter_svg/flutter_svg.dart'; // This is necessary for SvgPicture
import 'dart:math';
import '../../../services/socket_service.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final List<String> bios = [
    "Never give up 💪",
    "Live, Laugh, Love 🌟",
    "Keep going, you're doing great!",
    "Make today amazing ✨",
    "Believe in yourself! 💯",
    "Dream big, work hard! 💼",
    "Stay positive, stay strong!",
    "Don't stop until you're proud!",
    "Success is the best revenge 💥",
    "Embrace the journey 🚀",
  ];

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allItems = []; // ✅ Holds users + groups
  List<Map<String, dynamic>> _filteredItems = [];
  List<Map<String, dynamic>> _peopleList = []; // List for users (people)
  List<Map<String, dynamic>> _groupsList = []; // List for groups
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
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final loggedInUserId = userProvider.id; // Get current user's ID

      final users = await AuthService.fetchAllUsers(context);
      final groups = await GroupService.fetchGroups();
      print(
        "Groups fetched: ${groups.length}",
      ); // Add this debug line to check the number of groups

      setState(() {
        // Exclude the logged-in user from users list
        _allItems = [
          // Add groups as they are
          ...groups.map(
            (group) => {
              "type": "group",
              "id": group["id"],
              "name": group["name"],
              "members": group["groupUsers"],
              'totalMembers': null, // Initialize totalMembers as null for now
            },
          ),

          // Add only users who are NOT the logged-in user
          ...users
              .where((user) => user["id"] != loggedInUserId)
              .map(
                (user) => {
                  "type": "user",
                  "id": user["id"],
                  "name": user["username"],
                  "profilePicture": user["profilePicture"],
                },
              ),
        ];
        print("Groups fetched: ${_groupsList.length} groups");

        final random = Random(); // Random instance to select bio

        // Separate lists for users and groups
        _peopleList =
            _allItems.where((item) => item["type"] == "user").map((user) {
              // Assign a random bio to each user
              if (user["type"] == "user") {
                user['bio'] = bios[random.nextInt(bios.length)];
              }
              return user;
            }).toList();

        // Now, fetch group member data
        _groupsList =
            _allItems.where((item) => item["type"] == "group").toList();
        _groupsList.forEach((group) {
          print("Fetching members for group: ${group['name']}");

          fetchGroupMembersAndUpdateUI(
            group["id"],
          ); // Fetch group members and update totalMembers
        });

        // Initially set _filteredItems to all valid items
        _filteredItems = List.from(_allItems);
        _isLoading = false;
      });
    } catch (e) {
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

      // Update filtered people and groups
      _peopleList =
          _filteredItems.where((item) => item["type"] == "user").toList();
      _groupsList =
          _filteredItems.where((item) => item["type"] == "group").toList();
    });
  }

  void fetchGroupMembersAndUpdateUI(String groupId) {
    print("Fetching group members for groupId: $groupId");

    SocketService().fetchGroupMembers(groupId, (totalMembers, onlineMembers) {
      print(
        "Fetched members for groupId: $groupId, totalMembers: $totalMembers, onlineMembers: $onlineMembers",
      );

      setState(() {
        final groupIndex = _groupsList.indexWhere(
          (group) => group['id'] == groupId,
        );

        if (groupIndex != -1) {
          // Update group with totalMembers
          _groupsList[groupIndex]['totalMembers'] =
              totalMembers; // Set total members
          _groupsList[groupIndex]['onlineMembers'] =
              onlineMembers; // Set online members (optional)
          print(
            "Updated group with totalMembers: ${_groupsList[groupIndex]['totalMembers']}",
          );
        } else {
          print("Group not found for groupId: $groupId");
        }
      });
    }, mounted);
  }

  Widget _buildItemTile(Map<String, dynamic> item) {
    final isGroup = item["type"] == "group";

    // Display the random bio for each user
    String bio = item['bio'] ?? "No bio available"; // Use the random bio

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading:
            isGroup
                ? GroupCollageAvatar(members: item["members"])
                : CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      item["profilePicture"] != null &&
                              item["profilePicture"].isNotEmpty
                          ? NetworkImage(
                            '${AppConfig.serverIp}${item["profilePicture"]}',
                          )
                          : null,
                  child:
                      (item["profilePicture"] == null ||
                              item["profilePicture"].isEmpty)
                          ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          )
                          : null,
                ),
        title: Text(
          item["name"] ?? "Unknown",
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Color(0xFF000E08),
          ),
        ),
        subtitle:
            isGroup
                ? Text(
                  "", // Show total members for groups
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                )
                : Text(
                  bio, // Display the random bio here for users only
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

        onTap: () {
          if (isGroup) {
            _navigateToGroupChat(item["id"], item["name"]);
          } else {
            _navigateToChat(item["id"], item["name"], item["profilePicture"]);
          }
        },
      ),
    );
  }

  void _navigateToChat(
    String receiverId,
    String receiverName,
    String? receiverProfileImage,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChatScreen(
              receiverId: receiverId,
              receiverName: receiverName,
              receiverProfileImage: receiverProfileImage,
            ),
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
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(
          70,
        ), // 🔹 Increased height for spacing
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.end, // 🔹 Align search bar near the bottom
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width *
                    0.05, // 🔹 5% horizontal padding
              ).copyWith(top: 20), // 🔹 Add space from the top
              child: Container(
                height: 48, // 🔹 Slightly larger height for better usability
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F6), // 🔹 Light grey background
                  borderRadius: BorderRadius.circular(15), // 🔹 Rounded edges
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                  decoration: InputDecoration(
                    hintText: "People",
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Colors.black45,
                      fontFamily: 'Poppins',
                    ),
                    border: InputBorder.none, // No border
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ), // Adjust vertical alignment for text
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.asset(
                        'assets/icons/Search.svg', // Path to your SVG file
                        colorFilter: ColorFilter.mode(
                          Colors.black54, // Set the color you want to apply
                          BlendMode
                              .srcIn, // Use the srcIn blend mode to apply the color
                        ),
                        width: 20, // Width of the icon
                        height: 20, // Height of the icon
                        fit:
                            BoxFit
                                .contain, // Ensure the aspect ratio is preserved
                      ),
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.black54,
                              ), // ❌ Clear Icon
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                            : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                // <-- Wrap entire body with SingleChildScrollView
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // People Section
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                      child: Text(
                        "People",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: Color(0xFF000E08),
                        ),
                      ),
                    ),
                    // People List
                    _peopleList.isEmpty
                        ? const Center(
                          child: Text(
                            "No users found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap:
                              true, // <-- Allow this ListView to shrink to fit its content
                          physics:
                              NeverScrollableScrollPhysics(), // <-- Disable scrolling on People list
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _peopleList.length,
                          itemBuilder:
                              (_, index) => _buildItemTile(_peopleList[index]),
                        ),
                    // Group Section
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 0, 10),
                      child: Text(
                        "Group Chat",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: Color(0xFF000E08),
                        ),
                      ),
                    ),
                    // Group Chat List
                    _groupsList.isEmpty
                        ? const Center(
                          child: Text(
                            "No groups found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap:
                              true, // <-- Allow this ListView to shrink to fit its content
                          physics:
                              NeverScrollableScrollPhysics(), // <-- Disable scrolling on Group Chat list
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: _groupsList.length,
                          itemBuilder:
                              (_, index) => _buildItemTile(_groupsList[index]),
                        ),
                  ],
                ),
              ),
    );
  }
}
