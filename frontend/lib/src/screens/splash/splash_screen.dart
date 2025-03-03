import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../../services/socket_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/group_service.dart'; // ✅ Import GroupService
import '../onboarding/onboarding_screen.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
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
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    bool isAuth = await AuthService.isAuthenticated(context);
    if (!mounted) return;

    if (isAuth) {
      await AuthService.fetchUserData(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final socketService = Provider.of<SocketService>(context, listen: false);
      final messageProvider = Provider.of<MessageProvider>(
        context,
        listen: false,
      );

      if (userProvider.id != null && userProvider.id!.isNotEmpty) {
        // ✅ Fetch group IDs before connecting to socket
        final groups = await GroupService.fetchGroups();
        final groupIds = groups.map((group) => group["id"].toString()).toList();

        socketService.connect(
          userProvider.id!,
          groupIds,
        ); // ✅ Fix: Pass both userId & groupIds

        // ✅ Attach global message listener
        socketService.listenForMessages((data) {
          messageProvider.addMessage(data);
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
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
