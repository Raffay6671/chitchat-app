import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart'; // ✅ Import Bottom Navbar

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 4; // ✅ Set index to 4 for Settings

  void _onTabTapped(int index) {
    if (index != 4) { // ✅ Prevent redundant navigation on settings
      Navigator.pop(context); // ✅ Return to the main screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF3D4A7A),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          "Settings Screen",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ), // ✅ Bottom Navbar Visible
    );
  }
}
