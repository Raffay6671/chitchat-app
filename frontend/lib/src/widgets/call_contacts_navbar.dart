import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/searchscreen/user_search_screen.dart';

class CallNavBar extends StatelessWidget {
  final String title; // ✅ Dynamically Pass Title
  final String rightIconPath; // ✅ Dynamically Pass Right Icon Path

  const CallNavBar({
    super.key,
    required this.title,
    required this.rightIconPath, // ✅ Required right icon parameter
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 🔍 Left Circular Icon with Custom SVG
          _buildCircularIcon(context, "assets/icons/Search.svg"), // ✅ Left SVG (Search)

          // 📞 Centered Title Text (Now Passed Dynamically)
          Container(
            width: 110,
            height: 20,
            alignment: Alignment.center,
            child: Text(
              title, // ✅ Now uses the passed title dynamically
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700, // ✅ Bold (700)
                fontSize: 23, // ✅ Font Size
                height: 1.0, // ✅ Proper line height
                letterSpacing: 0,
                color: Colors.white, // ✅ Text color
              ),
            ),
          ),

          // 🔍 Right Circular Icon (Now Passed Dynamically)
          _buildCircularIcon(context, rightIconPath), // ✅ Right Icon (Dynamic)
        ],
      ),
    );
  }

  /// ✅ Reusable Circular Icon with Custom SVG
  Widget _buildCircularIcon(BuildContext context, String svgPath) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconButton(
          icon: SvgPicture.asset(
            svgPath,
            width: 28,
            height: 23,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () {
            // ✅ Navigate to Search Screen (You can modify this action based on which icon is clicked)
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
