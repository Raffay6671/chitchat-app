import 'package:flutter/material.dart';
import '../../widgets/call_contacts_navbar.dart'; // ✅ Import CallNavBar
import '../../widgets/calluser_container.dart'; // ✅ Import CallUserContainer

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Background Color Matches Home Screen
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
              title: "Calls", 
              rightIconPath: "assets/icons/addcall.svg", // ✅ Example of a different right icon
            ),                const SizedBox(height: 20), // ✅ Space between navbar & container
                const CallUserContainer(), // ✅ Contact List from Phone Book
              ],
            ),
          ),
        ],
      ),
    );
  }
}
