import 'package:flutter/material.dart';
import '../constants/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor; // Allow null for gradient usage
  final double borderRadius;
  final bool useGradient;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor, // Allow solid background color
    this.borderRadius = 24, // Default border radius
    this.useGradient = false, // Enable gradient if needed
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: useGradient ? Colors.transparent : backgroundColor, // Gradient or solid color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius), // Custom border radius
          ),
          elevation: 0, // No shadow for cleaner design
        ),
        child: Ink(
          decoration: useGradient
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A), // Dark navy blue
                      Color(0xFF2E1A47), // Deep purple
                      Color(0xFF334155), // Steel blue
                      Color(0xFF1E293B), // Charcoal
                    ],
                    stops: [0.0, 0.3, 0.65, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                )
              : null,
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.signUpButtonText, // Use centralized button text style
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
