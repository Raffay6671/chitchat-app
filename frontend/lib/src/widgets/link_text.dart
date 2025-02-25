import 'package:flutter/material.dart';
import '../constants/text_styles.dart';

class LinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const LinkText({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.linkText, // Apply centralized link text style
      ),
    );
  }
}
