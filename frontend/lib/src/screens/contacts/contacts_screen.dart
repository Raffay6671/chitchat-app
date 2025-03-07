import 'package:flutter/material.dart';
import '../../widgets/call_contacts_navbar.dart'; // ✅ Import CallNavBar
import '../../widgets/contactsuser_container.dart'; // ✅ Import CallUserContainer

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

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
                CallNavBar(
                  title: "Contacts",
                  rightIconPath:
                      "assets/icons/addcall.svg", // ✅ Example of a different right icon
                ),
                const SizedBox(
                  height: 45,
                ), // ✅ Space between navbar & container
                const ContactUsersContainer(), // ✅ Contact List from Phone Book
              ],
            ),
          ),
        ],
      ),
    );
  }
}
