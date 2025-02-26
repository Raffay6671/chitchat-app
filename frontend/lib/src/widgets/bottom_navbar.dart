import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF3D4A7A), // Active tab color
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavItem("assets/icons/message.svg", "Messages", 0, currentIndex),
        _buildNavItem("assets/icons/calls.svg", "Calls", 1, currentIndex),
        _buildNavItem("assets/icons/contacts.svg", "Contacts", 2, currentIndex),
        _buildNavItem("assets/icons/settings.svg", "Settings", 3, currentIndex),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(
      String iconPath, String label, int index, int currentIndex) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(
          currentIndex == index ? const Color(0xFF3D4A7A) : const Color.fromARGB(255, 36, 31, 31),
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }
}
