import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../../services/socket_service.dart';
import '../../../services/auth_service.dart';
import '../onboarding/onboarding_screen.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart'; // Import HomeScreen for navigation
import '../../providers/user_provider.dart';
import '../../providers/message_provider.dart';
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

  Future<void> _checkAuthentication() async {
    // Simulate some delay for splash
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    // 1) Check if user is already authenticated
    bool isAuth = await AuthService.isAuthenticated(context);
    if (!mounted) return;

    if (isAuth) {
      // 2) Fetch user data to set userProvider.id
      await AuthService.fetchUserData(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final socketService = Provider.of<SocketService>(context, listen: false);
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);

      // 3) If ID is set, connect the socket & attach global listener
      if (userProvider.id != null && userProvider.id!.isNotEmpty) {
        socketService.connect(userProvider.id!);
        socketService.listenForMessages((data) {
          messageProvider.addMessage(data);
        });
      }

      // 4) Go to Home Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Not authenticated => Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
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
