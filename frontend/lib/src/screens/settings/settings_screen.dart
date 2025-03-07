import 'package:flutter/material.dart';
import '../../widgets/settings_navbar.dart'; // ✅ Import SettingsNavBar
import '../../widgets/settings_user_container.dart'; // ✅ Import SettingsUserContainer
import '../../widgets/bottom_navbar.dart'; // ✅ Import BottomNavBar

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Background Color Matches Home Screens
      body: Stack(
        children: [
          // 🌈 Gradient Background (Same as Home Screen)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Dark Navy
                  Color(0xFF2E1A47), // Midnight Purple
                  Color(0xFF334155), // Steel Blue
                  Color(0xFF1E293B), // Charcoal
                ],
                stops: [0.0, 0.3, 0.65, 1.0],
              ),
            ),
          ),

          // 📶 Noise Overlay (Consistent Visual)
          Opacity(
            opacity: 0.03,
            child: Image.asset(
              'assets/images/noise_texture.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 🏠 Main UI Layout
          SafeArea(
            child: Column(
              children: [
                const SettingsNavBar(), // ✅ Settings Navbar
                const SizedBox(
                  height: 40,
                ), // ✅ Space between navbar & container
                const Expanded(
                  child: SettingsUserContainer(), // ✅ Settings User Container
                ),
              ],
            ),
          ),
        ],
      ),
      // Add the BottomNavBar here to keep it visible across screens
      bottomNavigationBar: BottomNavBar(
        currentIndex:
            4, // Set to Settings index (or your selected index for Settings)
        onTap: (index) {
          // Handle tap as needed (navigate to the respective screen)
          if (index == 0) {
            Navigator.pushNamed(
              context,
              '/home',
            ); // Example to navigate to Home
          }
        },
      ),
    );
  }
}
