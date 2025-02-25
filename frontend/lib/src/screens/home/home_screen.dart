import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart'; 
import '../../../services/auth_service.dart'; 
import '../../widgets/top_navbar.dart'; 
import '../../constants/colors.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ✅ Fetch user data when screen initializes
  }

  // ✅ Fetch user data from backend and store in Provider
  Future<void> _fetchUserData() async {
    await AuthService.fetchUserData(context);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Fetch user data from Provider
    final userProvider = Provider.of<UserProvider>(context);
    final profilePicture = userProvider.profilePicture;
    final username = userProvider.username ?? "N/A";
    final email = userProvider.email ?? "N/A";
    final displayName = userProvider.displayName ?? "N/A";
    final userId = userProvider.id ?? "N/A";

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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Top Navigation Bar
                    const TopNavBar(),

                    // ✅ Display User Data
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            const Text(
                              "User Information",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // ✅ Make text visible on gradient
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 👤 Profile Picture Display
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: profilePicture != null
                                    ? NetworkImage('http://10.0.2.2:5000$profilePicture')
                                    : null,
                                child: profilePicture == null
                                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 📄 User Details
                            Text("ID: $userId",
                                style: const TextStyle(fontSize: 18, color: Colors.white)),
                            const SizedBox(height: 10),
                            Text("Username: $username",
                                style: const TextStyle(fontSize: 18, color: Colors.white)),
                            const SizedBox(height: 10),
                            Text("Display Name: $displayName",
                                style: const TextStyle(fontSize: 18, color: Colors.white)),
                            const SizedBox(height: 10),
                            Text("Email: $email",
                                style: const TextStyle(fontSize: 18, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
