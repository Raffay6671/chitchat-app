import 'package:flutter/material.dart';
import 'colors.dart'; // Import color constants

class AppTextStyles {
  // Splash Screen Text Style
  static const TextStyle splashTitle = TextStyle(
    fontFamily: 'Acme', // Custom font
    fontSize: 72, // Size from Figma design
    fontWeight: FontWeight.w400, // Regular weight
    height: 1.1, // Line height (approximation)
    letterSpacing: 0, // No letter spacing
    color: AppColors.white, // Text color
  );

  // Onboarding Screen Main Heading
  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: 'Poppins', // Poppins font
    fontWeight: FontWeight.w500, // Medium weight for slightly lighter text
    fontSize: 72, // Font size
    height: 1.2, // Increased line height for better vertical spacing
    letterSpacing: 1.2, // Wider letter spacing
    color: AppColors.white, // White text color
  );

  // Onboarding Screen Subheading Paragraph with increased font size
static const TextStyle onboardingSubtitle = TextStyle(
  fontFamily: 'Poppins', // Poppins font
  fontWeight: FontWeight.w400, // Regular weight
  fontSize: 16, // Increased font size from 16 to 18
  height: 26 / 18, // Adjusted line height for the new font size
  letterSpacing: 0, // No letter spacing
  color: Color(0x80FFFFFF), // White with 50% opacity
);


// Sign Up Button Text Style
static const TextStyle signUpButtonText = TextStyle(
  fontFamily: 'Poppins', // Poppins font
  fontWeight: FontWeight.w600, // Medium weight
  fontSize: 16, // Font size
  height: 1.0, // Exact line height
  letterSpacing: 0, // No letter spacing
  color: AppColors.white, // Text color set to white
);



// Existing Account Text Style
static const TextStyle existingAccountText = TextStyle(
  fontFamily: 'Poppins', // Poppins font
  fontWeight: FontWeight.w400, // Regular weight
  fontSize: 15, // Font size
  height: 1.0, // Line height
  letterSpacing: 0.1, // Letter spacing
  color: AppColors.white, // White color
);

// Log In Link Text Style
static const TextStyle loginLinkText = TextStyle(
  fontFamily: 'Poppins', // Poppins font
  fontWeight: FontWeight.w600, // Slightly bolder weight
  fontSize: 15, // Font size
  height: 1.0, // Line height
  letterSpacing: 0.1, // Letter spacing
  color: AppColors.white, // White color for link
  decoration: TextDecoration.underline, // Underlined text to indicate interactivity
);



// Login Page Main Heading Text Style
static const TextStyle loginHeading = TextStyle(
  fontFamily: 'Poppins', // Poppins font
  fontWeight: FontWeight.w800, // Bold weight
  fontSize: 20, // Font size
  height: 1.0, // Line height
  letterSpacing: 0, // No letter spacing
  color: Color(0xFF3D4A7A), // Custom color
);


// Login Page Subheading Text Style
static const TextStyle loginSubheading = TextStyle(
  fontFamily: 'Poppins', // Poppins font
  fontWeight: FontWeight.w300, // Light weight
  fontSize: 14, // Font size
  height: 20 / 14, // Line height
  letterSpacing: 0.1, // Letter spacing
  color: Color(0xFF797C7B), // Light grey color from Figma
);

// Placeholder Text Style
static const TextStyle placeholderText = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400, // Regular weight
  fontSize: 16, // Font size
  height: 1.0, // Line height
  letterSpacing: 0, // No letter spacing
  color: Color(0x66000E08), // Slightly transparent dark color
);

// Input Text Style
static const TextStyle inputText = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w400, // Regular weight
  fontSize: 16, // Font size
  height: 1.0, // Line height
  letterSpacing: 0, // No letter spacing
  color: Colors.black, // Regular text color
);
// Log In Button Text Style
static const TextStyle loginButtonText = TextStyle(
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w700, // Bold
  fontSize: 16, // Font size
  height: 1.0, // Line height
  letterSpacing: 0, // No letter spacing
  color: Colors.white, // White text color
);

// Reusable Link Text Style
static const TextStyle linkText = TextStyle(
  fontFamily: 'Poppins', // Poppins font
  fontWeight: FontWeight.w600, // Medium weight
  fontSize: 14, // Font size
  height: 1.0, // Line height
  letterSpacing: 0.1, // Slight letter spacing
  color: Color(0xFF3D4A7A), // Text color from Figma
);

}
