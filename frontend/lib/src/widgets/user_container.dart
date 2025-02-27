import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/chatscreen/chat_screen.dart'; // Import Chat Screen

class UserContainer extends StatelessWidget {
  final List<Map<String, String>> users; // List of users passed to this widget

  const UserContainer({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.id; // Get the logged-in user's ID

    // 🔥 Filter out the logged-in user from the users list
    final filteredUsers = users.where((user) => user["id"] != userId).toList();

    return Expanded(
      child: Container(
        width: double.infinity, // Ensure it takes full width
        padding: const EdgeInsets.all(16.0), // Inside padding for content
        decoration: const BoxDecoration(
          color: Colors.white, // Background color of the container
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Rounded top-left corner
            topRight: Radius.circular(30), // Rounded top-right corner
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items at the top
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Vertical Scrollable List of Users
            Expanded(
              child: ListView.separated(
                itemCount: filteredUsers.length, // Number of filtered users
                separatorBuilder: (context, index) => const Divider(
                  thickness: 0.3, // Subtle divider for better UI
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index]; // Only show filtered users
                  final fullName = user["username"]; // Full name of the user
                  final profileImage = user["profilePicture"]; // Profile image of the user
                  final receiverId = user["id"]; // ID of the selected user

                  return GestureDetector(
                    onTap: () {
                      // ✅ Navigate to ChatScreen when user is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            receiverId: receiverId!,
                            receiverName: fullName ?? "Unknown",
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          // Profile Picture
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300], // Placeholder background
                            backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                                ? NetworkImage('http://10.10.20.5:5000$profileImage')
                                : null,
                            child: (profileImage == null || profileImage.isEmpty)
                                ? const Icon(Icons.person, size: 30, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 15),
                          // Full Name Text
                          Expanded(
                            child: Text(
                              fullName ?? "Full Name Not Available", // Display user full name
                              style: const TextStyle(
                                color: Color(0xFF000E08), // Set color according to Figma
                                fontFamily: 'Poppins', // Apply Poppins font
                                fontWeight: FontWeight.w500, // Font weight 500
                                fontSize: 20, // Font size 20px
                                height: 1.0, // Line height
                                letterSpacing: 0.0, // No letter spacing
                              ),
                            ),
                          ),
                          // Chat Icon Button
                          IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                            onPressed: () {
                              // ✅ Navigate to ChatScreen when chat icon is pressed
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverId: receiverId!,
                                    receiverName: fullName ?? "Unknown",
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
