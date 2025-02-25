import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../../services/auth_service.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/home_screen.dart'; // Import HomeScreen for navigation

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // ✅ Check if the user is authenticated
  Future<void> _checkAuthentication() async {
    await Future.delayed(const Duration(seconds: 3)); // Simulate splash screen duration
      if (!mounted) return; // Check if the widget is still mounted


    bool isAuthenticated = await AuthService.isAuthenticated(context);

    if (mounted) {
      if (isAuthenticated) {
        // Navigate to Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // Navigate to Onboarding Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
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
          ),

          // Noise Overlay for Smoother Visual Effect
          Opacity(
            opacity: 0.03,
            child: Image.asset(
              'assets/images/noise_texture.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Content
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/chat_bubble.svg',
                  width: 333.33,
                  height: 316.79,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 90,
                  child: Text(
                    'Chitchat',
                    style: AppTextStyles.splashTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
