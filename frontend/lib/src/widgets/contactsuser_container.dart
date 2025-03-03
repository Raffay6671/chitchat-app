import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import '../../src/constants/colors.dart'; // Import AppColors

class ContactUsersContainer extends StatefulWidget {
  const ContactUsersContainer({super.key});

  @override
  State<ContactUsersContainer> createState() => _CallUserContainerState();
}

class _CallUserContainerState extends State<ContactUsersContainer> {
  List<Contact> _contacts = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Map<String, List<Contact>> groupedContacts = {};

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      // ✅ Sorting Contacts Alphabetically
      contacts.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );

      // ✅ Grouping Contacts by First Letter
      Map<String, List<Contact>> grouped = {};
      for (var contact in contacts) {
        String firstLetter =
            contact.displayName.isNotEmpty
                ? contact.displayName[0].toUpperCase()
                : "#"; // If empty, put in "#"

        if (!grouped.containsKey(firstLetter)) {
          grouped[firstLetter] = [];
        }
        grouped[firstLetter]!.add(contact);
      }

      setState(() {
        _contacts = contacts;
        groupedContacts = grouped;
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
              "My Contacts",
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
                          "No Contacts Found",
                          style: TextStyle(
                            color: AppColors.grey,
                          ), // ✅ Using Centralized Color
                        ),
                      )
                      : ListView.builder(
                        itemCount: groupedContacts.keys.length,
                        itemBuilder: (context, index) {
                          String letter = groupedContacts.keys.elementAt(index);
                          List<Contact> contacts = groupedContacts[letter]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ✅ Section Header for Alphabet
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 10,
                                ),
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color:
                                        AppColors
                                            .black, // ✅ Using Centralized Color
                                  ),
                                ),
                              ),

                              // ✅ Displaying Contacts under this Section
                              Column(
                                children:
                                    contacts.map((contact) {
                                      final contactName = contact.displayName;
                                      final contactPhoto = contact.photo;
                                      final randomColor =
                                          AppColors.avatarColors[_random
                                              .nextInt(
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
                                                        ? contactName[0]
                                                            .toUpperCase()
                                                        : "?",
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                      );
                                    }).toList(),
                              ),
                            ],
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
