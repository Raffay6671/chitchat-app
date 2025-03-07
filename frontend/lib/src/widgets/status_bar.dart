// File: lib/widgets/status_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../../config.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profilePicture = userProvider.profilePicture;
    final userId = userProvider.id;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),

          // Horizontal ListView for My Status and Other Users
          SizedBox(
            height: 100, // Adjust height as needed
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Display logged-in user's status with "+" icon
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior:
                            Clip.none, // Allow overflow for the "+" icon
                        children: [
                          // Profile picture
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                profilePicture != null
                                    ? NetworkImage(
                                      '${AppConfig.serverIp}$profilePicture',
                                    )
                                    : null,
                            child:
                                profilePicture == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),

                          // Positioned "+" icon at the bottom right
                          Positioned(
                            bottom:
                                -5, // Adjust the icon to be outside the profile picture
                            right:
                                -5, // Adjust the icon to be at the bottom-right
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white,
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "My Status",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Display other users' status (display name and profile picture)
                FutureBuilder(
                  future: AuthService.fetchAllUsers(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: 100, // Match Status Bar Height
                        width: double.infinity, // ✅ Take full width
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // ✅ Centers the loader
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final users = snapshot.data as List<Map<String, String>>;
                      return Row(
                        children:
                            users
                                .where(
                                  (user) => user["id"] != userId,
                                ) // Exclude logged-in user
                                .map((user) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                            '${AppConfig.serverIp}${user["profilePicture"]}',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          user["displayName"]!, // Display Name should be used here
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                })
                                .toList(),
                      );
                    }
                    return const Text("No Users Available");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
