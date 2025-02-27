import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'src/screens/splash/splash_screen.dart';
import 'src/screens/onboarding/onboarding_screen.dart';
import 'src/screens/login/login_screen.dart';
import 'src/screens/signup/signup_screen.dart';
import 'src/screens/home/home_screen.dart';
import 'src/screens/chatscreen/chat_screen.dart';
import 'src/providers/user_provider.dart';
import './services/socket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => SocketService()),
        ],
        child: const ChitChatApp(),
      ),
    );
  });
}

class ChitChatApp extends StatelessWidget {
  const ChitChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chitchat',
      theme: ThemeData(
        fontFamily: 'Acme',
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // If you need a default /chat route, note it uses dummy values here:
        '/chat': (context) => ChatScreen(
              receiverId: '',
              receiverName: '',
              receiverProfileImage: null,
            ),
      },
    );
  }
}
