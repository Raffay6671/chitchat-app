import 'package:flutter/material.dart';
import 'custom_clippers.dart';
import '../../config.dart';

class GroupCollageAvatar extends StatelessWidget {
  final List<dynamic> members; // List of members with profilePicture

  const GroupCollageAvatar({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    // ✅ Take only the first 3 profile pictures for the collage
    final profilePics =
        members
            .map((member) => member["profilePicture"])
            .where((pic) => pic != null && pic.isNotEmpty)
            .take(3)
            .toList();

    // ✅ Placeholder if no images exist
    if (profilePics.isEmpty) {
      return const CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey,
        child: Icon(Icons.group, color: Colors.white, size: 24),
      );
    }

    return SizedBox(
      width: 60, // Adjust width for collage effect
      height: 60, // Adjust height for collage effect
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ✅ Left Half Image, check if the profilePics list has at least 1 item
          if (profilePics.isNotEmpty)
            Positioned.fill(
              child: ClipPath(
                clipper: LeftHalfClipper(),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    "${AppConfig.serverIp}${profilePics[0]}",
                  ),
                ),
              ),
            ),

          // ✅ Top Right Image, check if the profilePics list has at least 2 items
          if (profilePics.length > 1)
            Positioned.fill(
              child: ClipPath(
                clipper: TopRightClipper(),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    "${AppConfig.serverIp}${profilePics[1]}",
                  ),
                ),
              ),
            ),

          // ✅ Bottom Right Image, check if the profilePics list has at least 3 items
          if (profilePics.length > 2)
            Positioned.fill(
              child: ClipPath(
                clipper: BottomRightClipper(),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    "${AppConfig.serverIp}${profilePics[2]}",
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
