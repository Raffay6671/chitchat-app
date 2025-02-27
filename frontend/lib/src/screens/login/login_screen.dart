import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/auth_heading.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/link_text.dart';
import '../../../services/auth_service.dart';
import '../../../services/socket_service.dart';
import '../../providers/user_provider.dart';
import '../../providers/message_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Regex for validation
  final RegExp _emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  final RegExp _passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$');

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await AuthService.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      context: context,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      if (!mounted) return;

      // ✅ Socket + Listener Setup
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final socketService = Provider.of<SocketService>(context, listen: false);
      final messageProvider = Provider.of<MessageProvider>(context, listen: false);

      if (userProvider.id != null && userProvider.id!.isNotEmpty) {
        socketService.connect(userProvider.id!);

        // Attach our global message listener exactly ONCE
        // Off any old listener (if any), then reattach
        socketService.listenForMessages((data) {
          // Deduplicate by `data['id']` if your server provides unique IDs
          messageProvider.addMessage(data);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful!")),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AuthHeading(
                    title: "Log in to Chatbox",
                    subtitle: "Welcome back! Sign in with your email to continue.",
                  ),

                  // EMAIL
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: CustomTextField(
                      controller: _emailController,
                      placeholder: "Your Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email cannot be empty";
                        }
                        if (!_emailRegExp.hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                  ),

                  // PASSWORD
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: CustomTextField(
                      controller: _passwordController,
                      placeholder: "Password",
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        }
                        if (!_passwordRegExp.hasMatch(value)) {
                          return "Password must be at least 8 characters and contain letters+numbers";
                        }
                        return null;
                      },
                    ),
                  ),

                  // LOGIN BUTTON
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: SizedBox(
                      width: 370,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : CustomButton(
                              text: "Log in",
                              onPressed: _loginUser,
                              borderRadius: 16,
                              useGradient: true,
                            ),
                    ),
                  ),

                  // FORGOT PASSWORD
                  LinkText(
                    text: "Forgot password?",
                    onTap: () {
                      // ...
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
