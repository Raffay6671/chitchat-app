import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/searchscreen/user_search_screen.dart';

class CallNavBar extends StatelessWidget {
  final String title; // ✅ Dynamically Pass Title
  final String rightIconPath; // ✅ Dynamically Pass Right Icon Path

  const CallNavBar({
    super.key,
    required this.title,
    required this.rightIconPath,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double iconSize = screenWidth * 0.12; // Scale icons dynamically
        double textSize = screenWidth * 0.06; // Scale text size
        double paddingSize = screenWidth * 0.04; // Dynamic padding

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paddingSize, // Responsive horizontal padding
            vertical: paddingSize * 0.4, // Responsive vertical padding
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔍 Left Circular Icon with Custom SVG
              _buildCircularIcon(context, "assets/icons/Search.svg", iconSize),

              // 📞 Centered Title Text (Now Passed Dynamically)
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700, // ✅ Bold (700)
                  fontSize: textSize, // ✅ Responsive Font Size
                  color: Colors.white, // ✅ Text color
                ),
              ),

              // 🔍 Right Circular Icon (Now Passed Dynamically)
              _buildCircularIcon(context, rightIconPath, iconSize),
            ],
          ),
        );
      },
    );
  }

  /// ✅ Reusable Circular Icon with Custom SVG (Now Responsive)
  Widget _buildCircularIcon(
    BuildContext context,
    String svgPath,
    double iconSize,
  ) {
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconButton(
          icon: SvgPicture.asset(
            svgPath,
            width: iconSize * 0.6, // Scale SVG size
            height: iconSize * 0.6,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () {
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
