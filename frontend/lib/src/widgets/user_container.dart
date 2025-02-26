import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

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
        decoration: BoxDecoration(
          color: Colors.white, // Set the color of the container
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), // Rounded top-left corner
            topRight: Radius.circular(30), // Rounded top-right corner
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align items at the top
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Vertical Scrollable List of Users
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,  // Number of filtered users
                itemBuilder: (context, index) {
                  final user = filteredUsers[index]; // Only show filtered users
                  final fullName = user["username"];  // Full name of the user
                  final profileImage = user["profilePicture"];  // Profile image of the user

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: profileImage != null
                              ? NetworkImage('http://10.0.2.2:5000$profileImage')  // Use correct URL
                              : null,
                          child: profileImage == null
                              ? const Icon(Icons.person, size: 50, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        // Full Name Text
                        Expanded(
                          child: Text(
                            fullName ?? "Full Name Not Available", // Display user full name
                            style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',  // Apply Poppins font
                              fontWeight: FontWeight.w500, // Font weight 500
                              fontSize: 20, // Font size 20px
                              height: 4.0, // Line height (matches 20px from Figma)
                              letterSpacing: 0.0, // No letter spacing
                            ),
                          ),
                        ),
                      ],
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
