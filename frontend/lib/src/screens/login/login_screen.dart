import 'package:flutter/material.dart';
import '../../widgets/auth_heading.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/link_text.dart';
import '../../../services/auth_service.dart';

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

  // Regex for email and password validation
  final RegExp _emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$'); // Basic email pattern
  final RegExp _passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$'); // Minimum 8 characters, at least one letter and one number

  // Perform Login
void _loginUser() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  // ✅ Pass the context as a parameter
  var response = await AuthService.loginUser(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
    context: context, // ✅ Pass the context here
  );

  if (!mounted) return; // ✅ Check if the widget is still active

  setState(() => _isLoading = false);

  if (response.statusCode == 200) {
    if (!mounted) return; // ✅ Check before using context again

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login Successful!")),
    );

    // ✅ Redirect to the Home or Dashboard Page
    Navigator.pushReplacementNamed(context, '/home');
  } else {
    if (!mounted) return; // ✅ Check before using context again

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login Failed: ${response.body}")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Heading
                  AuthHeading(
                    title: "Log in to Chatbox",
                    subtitle:
                        "Welcome back! Sign in using your social account or email to continue.",
                  ),

                  // Email Input Field with Regex Validation
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
                        return null; // Valid input
                      },
                    ),
                  ),

                  // Password Input Field with Regex Validation
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
                          return "Password must be at least 8 characters, include letters and numbers";
                        }
                        return null; // Valid input
                      },
                    ),
                  ),

                  // Login Button
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: SizedBox(
                      width: 370,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : CustomButton(
                              text: "Log in",
                              onPressed: _loginUser,
                              borderRadius: 16,
                              useGradient: true,
                            ),
                    ),
                  ),

                  // Forgot Password Link
                  LinkText(
                    text: "Forgot password?",
                    onTap: () {
                      // Navigate to Forgot Password Page
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