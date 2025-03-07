import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import 'package:flutter/gestures.dart';
import '../../widgets/custom_button.dart'; // Import the custom button
import '../../screens/login/login_screen.dart'; // Import the login screen
import '../../screens/signup/signup_screen.dart'; // Import SignUpScreens

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get screen height dynamically
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkNavy,
              AppColors.midnightPurple,
              AppColors.steelBlue,
              AppColors.charcoal,
            ],
            stops: [0.0, 0.3, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Main Heading Text
            Positioned(
              top: screenHeight * 0.12, // ✅ 12% from the top (Responsive)
              left: 26,
              child: SizedBox(
                width: 350,
                child: Text(
                  "Connect friends easily & quickly",
                  style: AppTextStyles.onboardingTitle,
                  textAlign: TextAlign.start,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),

            // Subheading Paragraph
            Positioned(
              top: screenHeight * 0.58, // ✅ 55% of the screen height
              left: 26,
              child: SizedBox(
                width: 327,
                child: Text(
                  "Our chat app is the perfect way to stay connected with friends and family.",
                  style: AppTextStyles.onboardingSubtitle,
                  textAlign: TextAlign.start,
                ),
              ),
            ),

            // Sign-Up Button (Horizontally Centered)
            Positioned(
              top: screenHeight * 0.75, // ✅ 75% of the screen height
              left: 0,
              right: 0,
              child: Center(
                child: CustomButton(
                  text: "Sign up with email",
                  backgroundColor: AppColors.semiTransparentWhite,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  borderRadius: 24,
                ),
              ),
            ),

            // Existing Account Text with "Log in" Link
            Positioned(
              top: screenHeight * 0.85, // ✅ Adjusted for better visibility
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 200,
                  height: 20,
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.existingAccountText,
                      children: [
                        const TextSpan(text: "Existing account? "),
                        TextSpan(
                          text: "Log in",
                          style: AppTextStyles.loginLinkText,
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
