import 'package:flutter/material.dart';
import '../../config.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final bool isOnline; // Add a flag to check if the user is online

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40.0,
    this.isOnline = false, // Default to offline
  });

  @override
  Widget build(BuildContext context) {
    String fullUrl =
        imageUrl.startsWith("http")
            ? imageUrl
            : "${AppConfig.serverIp}$imageUrl"; // Complete URL

    return Stack(
      clipBehavior: Clip.none, // Allow the indicator to overflow the avatar
      children: [
        CircleAvatar(
          radius: size, // Size of the avatar
          backgroundColor: Colors.grey[300],
          backgroundImage: NetworkImage(fullUrl), // Image loading
          onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 24),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 8, // Small dot size
            height: 8,
            decoration: BoxDecoration(
              color:
                  isOnline
                      ? Colors.green
                      : Colors.grey, // Green if online, grey if offline
              shape: BoxShape.circle,
              // White border to make it visible
            ),
          ),
        ),
      ],
    );
  }
}
