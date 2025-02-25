import 'package:flutter/material.dart';
import '../constants/text_styles.dart';

class AuthHeading extends StatelessWidget {
  final String title; // Main heading text
  final String subtitle; // Subheading text
  final double topSpacing; // Spacing from the top for positioning

  const AuthHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.topSpacing = 145, // Default spacing for login screen
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Heading
        Padding(
          padding: EdgeInsets.only(top: topSpacing),
          child: Center(
            child: SizedBox(
              width: 200,
              height: 25,
              child: Text(
                title,
                style: AppTextStyles.loginHeading, // Custom heading style
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        // Subheading
        Padding(
          padding: const EdgeInsets.only(top: 35), // Spacing between heading and subheading
          child: Center(
            child: SizedBox(
              width: 293,
              height: 40,
              child: Text(
                subtitle,
                style: AppTextStyles.loginSubheading, // Custom subheading style
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
