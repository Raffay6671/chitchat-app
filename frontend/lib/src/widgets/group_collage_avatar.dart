import 'package:flutter/material.dart';
import 'custom_clippers.dart';

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

    // print("🎯 Selected Profile Pics for Collage: $profilePics");

    return SizedBox(
      width: 60, // Adjust width for collage effect
      height: 60, // Adjust height for collage effect
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ✅ Left Half Image
          Positioned.fill(
            child: ClipPath(
              clipper: LeftHalfClipper(),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    profilePics.isNotEmpty
                        ? NetworkImage(
                          "http://10.10.20.5:5000${profilePics[0]}",
                        )
                        : null,
              ),
            ),
          ),

          Positioned.fill(
            child: ClipPath(
              clipper: TopRightClipper(),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    profilePics.isNotEmpty
                        ? NetworkImage(
                          "http://10.10.20.5:5000${profilePics[1]}",
                        )
                        : null,
              ),
            ),
          ),
          Positioned.fill(
            child: ClipPath(
              clipper: BottomRightClipper(),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    profilePics.isNotEmpty
                        ? NetworkImage(
                          "http://10.10.20.5:5000${profilePics[2]}",
                        )
                        : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
