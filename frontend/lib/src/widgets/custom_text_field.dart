import 'package:flutter/material.dart';
import '../constants/text_styles.dart';
import '../constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String placeholder;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator; // Added validator parameter

  const CustomTextField({
    super.key,
    required this.placeholder,
    this.isPassword = false,
    this.controller,
    this.validator, // Accept the validator
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 327,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.inputFieldBackground, // Background color from Figma
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      child: TextFormField( // Changed from TextField to TextFormField
        controller: controller,
        obscureText: isPassword, // Hide text for password fields
        validator: validator, // Add validation support
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: AppTextStyles.placeholderText, // Placeholder style
          border: InputBorder.none, // Removes default borders
          contentPadding: const EdgeInsets.symmetric(horizontal: 16), // Padding inside the field
        ),
        style: AppTextStyles.inputText, // Actual input text style
      ),
    );
  }
}
