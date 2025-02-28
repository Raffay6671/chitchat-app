import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // ✅ Import UserProvider for fetching profile picture
import '../screens/searchscreen/user_search_screen.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Fetch user's profile picture from the Provider
    final profilePicture = Provider.of<UserProvider>(context).profilePicture;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔍 Left Circular Icon with Custom SVG
          _buildCircularSvgIcon(context, "assets/icons/Search.svg"), // ✅ Left SVG

          // 🏠 Centered "Home" Text
          Container(
            width: 60,
            height: 20,
            alignment: Alignment.center,
            child: const Text(
              'Home',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500, // 500 weight
                fontSize: 20,
                height: 1.0, // ✅ Proper line height equivalent
                letterSpacing: 0,
                color: Colors.white, // Text color
              ),
            ),
          ),

          // 👤 Profile Picture Icon Without Border
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: profilePicture != null
                  ? Image.network(
                      'http://10.10.20.5:5000$profilePicture',
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Reusable Circular Icon with Custom SVG
  Widget _buildCircularSvgIcon(BuildContext context, String svgPath) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconButton(
          icon: SvgPicture.asset(
            svgPath, // ✅ Dynamic SVG Path
            width: 23,
            height: 23,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () {
            // ✅ Navigate to the search screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserSearchScreen()),
            );
          },
        ),
      ),
    );
  }
}
