import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import '../../src/constants/colors.dart'; //Import AppColor

class CallUserContainer extends StatefulWidget {
  const CallUserContainer({super.key});

  @override
  State<CallUserContainer> createState() => _CallUserContainerState();
}

class _CallUserContainerState extends State<CallUserContainer> {
  List<Contact> _contacts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      setState(() {
        _contacts = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: AppColors.white, // ✅ Using Centralized Color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 "Recent" Title
            const Text(
              "Recent",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                height: 1.0,
                letterSpacing: 0,
                color: AppColors.black, // ✅ Using Centralized Color
              ),
            ),

            const SizedBox(height: 10),

            // 📞 Contact List
            Expanded(
              child:
                  _contacts.isEmpty
                      ? const Center(
                        child: Text(
                          "No Calls found",
                          style: TextStyle(
                            color: AppColors.grey,
                          ), // ✅ Using Centralized Color
                        ),
                      )
                      : ListView.separated(
                        itemCount: _contacts.length,
                        separatorBuilder:
                            (_, __) => const Divider(
                              thickness: 0.3,
                              color: AppColors.grey,
                            ), // ✅ Using Centralized Color
                        itemBuilder: (context, index) {
                          final contact = _contacts[index];
                          final contactName = contact.displayName;
                          final contactPhoto = contact.photo;
                          final randomColor =
                              AppColors.avatarColors[_random.nextInt(
                                AppColors.avatarColors.length,
                              )];

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  contactPhoto == null
                                      ? randomColor // ✅ Using Centralized Avatar Colors
                                      : Colors.transparent,
                              backgroundImage:
                                  contactPhoto != null
                                      ? MemoryImage(contactPhoto)
                                      : null,
                              child:
                                  contactPhoto == null
                                      ? Text(
                                        contactName.isNotEmpty
                                            ? contactName[0].toUpperCase()
                                            : "?",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              AppColors
                                                  .white, // ✅ Using Centralized Color
                                        ),
                                      )
                                      : null,
                            ),
                            title: Text(
                              contactName,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color:
                                    AppColors
                                        .black, // ✅ Using Centralized Color
                              ),
                            ),
                            subtitle: const Text(
                              "Today, 09:30 AM",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                color:
                                    AppColors.grey, // ✅ Using Centralized Color
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.call,
                                  color: AppColors.grey,
                                ), // ✅ Using Centralized Color
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.videocam,
                                  color: AppColors.grey,
                                ), // ✅ Using Centralized Color
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
