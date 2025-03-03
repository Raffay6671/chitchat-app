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
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const MessageScreen(),
    const CallsScreen(),
    const ContactsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Navigator(
          onGenerateRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) => _screens[_selectedIndex],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
