import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // ✅ Add Provider package

import 'src/screens/splash/splash_screen.dart';
import 'src/screens/onboarding/onboarding_screen.dart';
import 'src/screens/login/login_screen.dart';
import 'src/screens/signup/signup_screen.dart';
import 'src/screens/home/home_screen.dart'; // ✅ Import Home Screen
import 'src/providers/user_provider.dart'; // ✅ Import UserProvider

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()), // ✅ Initialize UserProvider
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
        primarySwatch: Colors.blue, // ✅ Add a primary theme color
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(), // ✅ Protected Home Page Route
      },
    );
  }
}
