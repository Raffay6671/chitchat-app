import 'package:flutter/material.dart';
import '../../widgets/auth_heading.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  // Email Regex for validation
  final RegExp _emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    var response = await AuthService.registerUser(
      username: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    // ✅ Always check if the widget is still mounted
    if (!mounted) return;

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User registered successfully!")));

      // ✅ Redirect to Login Page after successful registration
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Failed: ${response.body}")),
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
                    title: "Sign up with Email",
                    subtitle:
                        "Get chatting with friends and family today by signing up for our chat app!",
                  ),

                  // Input Fields
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: CustomTextField(
                      controller: _nameController,
                      placeholder: "Your Name",
                      validator:
                          (value) =>
                              value!.isEmpty ? "Name cannot be empty" : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: CustomTextField(
                      controller: _emailController,
                      placeholder: "Your Email",
                      validator:
                          (value) =>
                              !_emailRegExp.hasMatch(value!)
                                  ? "Enter a valid email"
                                  : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: CustomTextField(
                      controller: _passwordController,
                      placeholder: "Password",
                      isPassword: true,
                      validator:
                          (value) =>
                              !_passwordRegExp.hasMatch(value!)
                                  ? "Password must be at least 8 characters, include letters and numbers"
                                  : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: CustomTextField(
                      controller: _confirmPasswordController,
                      placeholder: "Confirm Password",
                      isPassword: true,
                      validator:
                          (value) =>
                              value != _passwordController.text
                                  ? "Passwords do not match"
                                  : null,
                    ),
                  ),

                  // Sign Up Button
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 20),
                    child: SizedBox(
                      width: 370,
                      child:
                          _isLoading
                              ? CircularProgressIndicator()
                              : CustomButton(
                                text: "Create an account",
                                onPressed: _registerUser,
                                borderRadius: 16,
                                useGradient: true,
                              ),
                    ),
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
