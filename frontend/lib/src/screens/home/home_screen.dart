import 'package:flutter/material.dart';
import '../../widgets/bottom_navbar.dart';
import '../messages/message_screen.dart';
import '../calls/calls_screen.dart';
import '../contacts/contacts_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default index, change based on navigation

  final List<Widget> _screens = [
    const MessageScreen(),
    const CallsScreen(),
    const ContactsScreen(),
    const SettingsScreen(),
  ];

  // Update the index when a tab is tapped
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index; // Correctly updates the active tab
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _screens[_selectedIndex], // Directly navigate based on selected index
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex, // Correctly highlight the selected tab
        onTap: _onTabTapped, // This will update the active tab
      ),
    );
  }
}
