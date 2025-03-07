import 'package:flutter/material.dart';

class SettingsNavBar extends StatelessWidget {
  const SettingsNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;
        double iconSize = screenWidth * 0.08; // Adjusted icon size
        double textSize = screenWidth * 0.06; // Adjusted text size
        double paddingSize = screenWidth * 0.02; // Adjusted padding

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: paddingSize, // Responsive padding
            vertical: paddingSize * 0.5, // Vertical spacing
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🔙 Left White Back Arrow
              IconButton(
                icon: Container(
                  width: 18, // Set the width for the icon
                  height: 15, // Set the height for the icon
                  child: Image.asset(
                    'assets/icons/whitenav.png', // Path to your custom image
                    fit:
                        BoxFit
                            .contain, // Ensure the image fits within the container
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // ✅ Navigate to the previous screen
                },
              ),

              // ⚙️ Centered "Settings" Title
              Text(
                "Settings",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: textSize,
                  color: Colors.white,
                ),
              ),

              // ✅ Empty space for alignment (No right icon)
              SizedBox(width: iconSize), // Keeps alignment consistent
            ],
          ),
        );
      },
    );
  }
}
