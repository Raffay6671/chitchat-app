import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    this.size = 40.0, // Default size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Ensure the image URL is complete
    String fullUrl =
        imageUrl.startsWith("http")
            ? imageUrl
            : "http://10.10.20.5:5000$imageUrl"; // Replace with your server's IP

    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[300],
      backgroundImage: NetworkImage(fullUrl), // ✅ Load full URL
      onBackgroundImageError: (_, __) => const Icon(Icons.person, size: 24),
    );
  }
}
