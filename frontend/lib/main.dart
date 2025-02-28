import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Screens
import 'src/screens/splash/splash_screen.dart';
import 'src/screens/onboarding/onboarding_screen.dart';
import 'src/screens/login/login_screen.dart';
import 'src/screens/signup/signup_screen.dart';
import 'src/screens/home/home_screen.dart';
import 'src/screens/chatscreen/chat_screen.dart';
import 'src/screens/creategroup/create_group_screen.dart'; // ✅ Import Group Screen
import 'src/screens/settings/settings_screen.dart';  // ✅ Import Settings Screen

// Providers
import 'src/providers/user_provider.dart';
import 'src/providers/message_provider.dart';
import 'services/socket_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(const ChitChatApp());
  });
}

class ChitChatApp extends StatelessWidget {
  const ChitChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),  // ✅ Manages user authentication state
        ChangeNotifierProvider(create: (_) => SocketService()), // ✅ Manages WebSocket connection
        ChangeNotifierProvider(create: (_) => MessageProvider()), // ✅ Manages chat messages globally
      ],
      child: MaterialApp(
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
          '/chat': (context) => ChatScreen(
                receiverId: '',
                receiverName: '',
                receiverProfileImage: null,
              ),
          '/group': (context) => const CreateGroupScreen(), // ✅ Added Group Page
          '/settings': (context) => const SettingsScreen(), // ✅ Added Settings Page
        },
      ),
    );
  }
}
