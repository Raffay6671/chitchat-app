import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/searchscreen/user_search_screen.dart';
import '../../config.dart';

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final profilePicture = Provider.of<UserProvider>(context).profilePicture;

    print("Profile Picture: $profilePicture");
    print(
      "Profile picture URL***MSMSMSS: ${AppConfig.serverIp}$profilePicture",
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double iconSize = screenWidth * 0.1; // Scale icons dynamically
        double textSize = screenWidth * 0.05; // Scale text size

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // Responsive horizontal padding
            vertical: screenWidth * 0.02, // Responsive vertical padding
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔍 Left Circular Search Icon
              _buildCircularSvgIcon(
                context,
                "assets/icons/Search.svg",
                iconSize,
              ),

              // 🏠 Centered "Home" Text
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Home',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: textSize,
                    height: 1.0,
                    letterSpacing: 0,
                    color: Colors.white,
                  ),
                ),
              ),

              // 👤 Profile Picture Icon (Scalable)
              Container(
                width: iconSize,
                height: iconSize,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child:
                      profilePicture != null
                          ? Image.network(
                            '${AppConfig.serverIp}$profilePicture',
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.person,
                            color: Colors.white,
                            size: iconSize * 0.5,
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ✅ Reusable Circular Icon with Custom SVG (Now Responsive)
  Widget _buildCircularSvgIcon(
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
