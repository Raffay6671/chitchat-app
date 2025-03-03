import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Primary Theme Colors (Matching Figma)
  static const Color darkNavy = Color(0xFF0F172A); // Dark navy blue
  static const Color midnightPurple = Color(0xFF2E1A47); // Deep purple
  static const Color steelBlue = Color(0xFF334155); // Soft steel blue
  static const Color charcoal = Color(0xFF1E293B); // Charcoal black tone

  // 🔹 Standard Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  // 🔹 Button Background Color
  static const Color buttonColor = Color(
    0xFF3D4A7A,
  ); // ✅ Matches the Figma Button (#3D4A7A)

  // 🔹 Semi-Transparent Colors (For overlays, inputs, etc.)
  static const Color semiTransparentWhite = Color(
    0x5EFFFFFF,
  ); // White with opacity (#FFFFFF5E)

  // 🔹 Input Field Background Color
  static const Color inputFieldBackground = Color(
    0xFFF3F6F6,
  ); // Input field background from Figma

  // 🔹 Avatar Background Colors (Used in CallUserContainer)
  static const List<Color> avatarColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.brown,
  ];

  // 🔹 Newly Added Background Color (As per request)
  static const Color lightPurpleBackground = Color(
    0x143D4A7A,
  ); // ✅ #3D4A7A14 (RGBA)

  //For the text color in the group creation screen
  static const Color darkGreyBackground = Color(
    0xFF272727,
  ); // ✅ Matches Figma Background (#272727)

  // 🔹 Newly Added Text Color for Group Creation Screen
  static const Color mutedGreyText = Color(
    0x80797C7B,
  ); // ✅ Matches Figma (#797C7B80)
}
