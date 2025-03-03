import 'package:flutter/material.dart';
import '../../widgets/top_navbar.dart';
import '../../widgets/status_bar.dart';
import '../../widgets/user_container.dart';
import '../../constants/colors.dart';
import '../../../services/auth_service.dart';
import 'dart:developer';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  bool _isLoading = true;
  List<Map<String, String>> users = [];

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    setState(() => _isLoading = true);

    try {
      List<Map<String, String>> fetchedUsers = await AuthService.fetchAllUsers(
        context,
      );
      log("Fetched Users: $fetchedUsers", name: "UserFetch");

      setState(() {
        users = fetchedUsers;
        _isLoading = false;
      });
    } catch (e) {
      log("Error fetching users: $e", name: "UserFetch", level: 1000);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // ✅ Refresh when user navigates back
      onWillPop: () async {
        _fetchAllUsers();
        return true;
      },
      child: Container(
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
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TopNavBar(),
                    const StatusBar(),
                    Expanded(child: UserContainer(users: users)), // ✅ Updated
                  ],
                ),
      ),
    );
  }
}
