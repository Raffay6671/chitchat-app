import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Import UserProvider
import '../../config.dart';

class SettingsUserContainer extends StatelessWidget {
  const SettingsUserContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Expanded(
      // Ensures it stretches to the bottom
      child: Stack(
        // Wrap the whole container with Stack
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
            decoration: const BoxDecoration(
              color: Colors.white, // Matches UI in image
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(70),
                topRight: Radius.circular(70),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Row
                ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        userProvider.profilePicture != null &&
                                userProvider.profilePicture!.isNotEmpty
                            ? NetworkImage(
                              '${AppConfig.serverIp}${userProvider.profilePicture}',
                            )
                            : const AssetImage(
                                  "assets/images/profile_placeholder.png",
                                )
                                as ImageProvider, // Use placeholder if no profile picture
                  ),
                  title: Text(
                    userProvider.username ??
                        "Unknown", // Display dynamic full name
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: const Text(
                    "Never give up 💪", // Static random bio
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.qr_code,
                      color: Colors.black,
                    ), // QR Code Icon
                    onPressed: () {
                      // Implement QR Code functionality here
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 20.0,
                    bottom: 10.0,
                  ), // Adjust the gap above and below the divider
                  child: Container(
                    width: double.infinity, // Ensure it takes the full width
                    height: 1, // Set the height to match the thickness (1px)
                    color: const Color(0xFFF5F6F6), // Set color to #F5F6F6
                  ),
                ),

                // Settings Options with gap between items
                Expanded(
                  // This makes the settings list take remaining space
                  child: ListView.separated(
                    itemCount: 4, // Set item count
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(
                        height: 16.0,
                      ); // Gap between each item
                    },
                    itemBuilder: (BuildContext context, int index) {
                      switch (index) {
                        case 0:
                          return _buildSettingsOption(
                            "Account",
                            "Privacy, security, change number",
                            "assets/images/key.png", // Path to key image
                            context,
                          );
                        case 1:
                          return _buildSettingsOption(
                            "Chat",
                            "Chat history, theme, wallpapers",
                            "assets/images/chat.png", // Path to chat image
                            context,
                          );
                        case 2:
                          return _buildSettingsOption(
                            "Notifications",
                            "Messages, group and others",
                            "assets/images/notify.png", // Path to notify image
                            context,
                          );
                        case 3:
                          return _buildSettingsOption(
                            "Invite a friend",
                            "",
                            "assets/images/invite.png", // Path to invite image
                            context,
                          );
                        default:
                          return SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // The slider for settings container
          Positioned(
            top: 18,
            left:
                MediaQuery.of(context).size.width *
                0.44, // Adjusted for better centering
            right:
                MediaQuery.of(context).size.width *
                0.44, // Adjusted for better centering
            child: Container(
              width: 40, // Reduced size of slider
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper function for each settings option
  Widget _buildSettingsOption(
    String title,
    String subtitle,
    String imagePath, // Accept image path
    BuildContext context,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFDEEBFF), // Light blue background color
        radius: 24, // Set the radius for the circle (adjust as needed)
        child: Image.asset(
          imagePath, // Path to image inside assets
          fit: BoxFit.contain, // Ensures image fits within the circle
          width: 24, // Adjust the width of the image inside the circle
          height: 24, // Adjust the height of the image inside the circle
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      subtitle:
          subtitle.isNotEmpty
              ? Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              )
              : null,
      onTap: () {
        // Implement navigation for each settings option
      },
    );
  }
}
