import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../constants/colors.dart';
import '../../../services/auth_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  List<Map<String, String>> selectedUsers = [];
  List<Map<String, String>> allUsers = []; // 🔹 Store all fetched users
  Set<String> invitedUserIds = {};
  String _groupName = ""; // ✅ Stores the entered group name



  

  @override
  void initState() {
    super.initState();
    _fetchAllUsers(); 
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  // ✅ Fetch all users from the backend
  Future<void> _fetchAllUsers() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final loggedInUserId = userProvider.id;
  
  List<Map<String, String>> users = await AuthService.fetchAllUsers(context);

  // ✅ Fix URLs here
  for (var user in users) {
    final pic = user["profilePicture"] ?? "";
    // If it doesn't start with "http", prepend your base URL
    if (pic.isNotEmpty && !pic.startsWith('http')) {
      user["profilePicture"] = "http://10.10.20.5:5000$pic";
    }
  }

  setState(() {
    // Exclude logged-in user
    allUsers = users.where((user) => user["id"] != loggedInUserId).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    // 🔥 Fetch the logged-in user from UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final loggedInUserName = userProvider.displayName ?? "Unknown User";
    final loggedInUserProfile = userProvider.profilePicture;

    return Scaffold(
      backgroundColor: AppColors.white, // ✅ White Background
      appBar: AppBar(
      backgroundColor: AppColors.white, // ✅ White background
      elevation: 0, // ✅ No shadow for a clean look
      centerTitle: true, // ✅ Center-align the title
      title: const Text(
        "Create Group",
        style: TextStyle(
          fontFamily: 'Poppins', // ✅ Correct Font Family
          fontWeight: FontWeight.w600, // ✅ Medium (500)
          fontSize: 17, // ✅ Font Size 16px
          height: 1.0, // ✅ Line Height 16px
          letterSpacing: 1.0, // ✅ No letter spacing
          color: Color(0xFF000E08), // ✅ Dark Greenish-Black Text Color
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    ),


      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Group Description
                  TextFormField(
                      controller: _groupNameController, // ✅ Keeps track of input
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500, // ✅ Same styling
                        fontSize: 16,
                        height: 1.0,
                        letterSpacing: 0.0,
                        color: Color(0xFF797C7B),
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none, // ✅ No border to match original UI
                        hintText: "Group Name",
                        hintStyle: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 1.0,
                          letterSpacing: 0.0,
                          color: Color(0xFF797C7B),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _groupName = value; // ✅ Stores the input dynamically
                        });
                      },
                    ),



                  const SizedBox(height:20),

                  // 🔹 Title: Make Group for Team Work
                 const Text(
                  "Make Group \nfor Team Work",
                  style: TextStyle(
                    fontFamily: 'Poppins', // ✅ Correct Font Family
                    fontWeight: FontWeight.w600, // ✅ Medium (500) (Closest to 550)
                    fontSize: 44, // ✅ Font Size 44px
                    height: 1.25, // ✅ Matches Line Height 50px (44 * 1.25 ≈ 55)
                    letterSpacing: 0.2, // ✅ Slightly Increase Spacing to Balance Weight
                    color: Color(0xFF000E08), // ✅ Deep Blackish Tone
                  ),
                  textAlign: TextAlign.left, // ✅ Aligns text properly
                ),



                  const SizedBox(height: 20),

                  // 🔹 Tags
                 Row(
                  children: [
                    _buildTag("Group work"),
                    const SizedBox(width: 8),
                    _buildTag("Team relationship"),
                  ],
                ),


                  const SizedBox(height: 30),

                  // 🔹 Group Admin Section (Dynamically Displays Logged-In User)
                  const Text(
                  "Group Admin",
                  style: TextStyle(
                    fontFamily: 'Poppins', // ✅ Correct Font Family
                    fontWeight: FontWeight.w600, // ✅ Weight 500
                    fontSize: 16, // ✅ Font Size 16px
                    height: 1.0, // ✅ Line Height 16px (16 * 1.0 = 16)
                    letterSpacing: 0.0, // ✅ No letter spacing
                    color: AppColors.darkGreyBackground, // ✅ Text color
                  ),
                ),

                  const SizedBox(height: 15),
                  ListTile(
                  leading: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.08, // ✅ Responsive Avatar Size
                    backgroundColor: Colors.purple.shade200,
                    backgroundImage: (loggedInUserProfile != null && loggedInUserProfile.isNotEmpty)
                        ? NetworkImage("http://10.10.20.5:5000$loggedInUserProfile") // ✅ Correctly Fetched Profile Picture
                        : null,
                    child: (loggedInUserProfile == null || loggedInUserProfile.isEmpty)
                        ? Icon(
                            Icons.person,
                            size: MediaQuery.of(context).size.width * 0.1, // ✅ Responsive Icon Size
                            color: Colors.white,
                          )
                        : null,
                  ),
                  title: Text(
                    loggedInUserName,
                    style: TextStyle(
                      fontFamily: 'Poppins', // ✅ Correct Font Family
                      fontWeight: FontWeight.w500, // ✅ Medium (500)
                      fontSize: 16, // ✅ Font Size 16px
                      height: 1.0, // ✅ Matches Line Height 16px
                      letterSpacing: 0.0, // ✅ No letter spacing
                      color: Colors.black, // ✅ Ensure proper text color
                    ),
                  ),

                  subtitle: Text(
                  "Group Admin",
                  style: TextStyle(
                    fontFamily: 'Poppins', // ✅ Correct Font Family
                    fontWeight: FontWeight.w400, // ✅ Regular (400)
                    fontSize: 12, // ✅ Font Size 12px
                    height: 1.0, // ✅ Matches Line Height 12px
                    letterSpacing: 0.0, // ✅ No letter spacing
                    color: AppColors.mutedGreyText, // ✅ Uses new color from AppColors
                  ),
                ),

                ),


                  const SizedBox(height: 20),

                  // 🔹 Invited Members
                 const Text(
                "Invited Members",
                style: TextStyle(
                  fontFamily: 'Poppins', // ✅ Correct Font Family
                  fontWeight: FontWeight.w600, // ✅ Weight 500
                  fontSize: 16, // ✅ Font Size 16px
                  height: 1.0, // ✅ Line Height 16px (16 * 1.0 = 16)
                  letterSpacing: 0.0, // ✅ No letter spacing
                  color: AppColors.darkGreyBackground, // ✅ Text color
                ),
              ),

                  const SizedBox(height: 10),

                  // 🔹 Members Grid
                  _buildInvitedMembersGrid(),

                  const SizedBox(height: 20),






                  //This part id to fetch all the users from the database 
                  const SizedBox(height: 20),

                  // 🔹 Invited Members
                    const Text(
                    "Members",
                    style: TextStyle(
                      fontFamily: 'Poppins', // ✅ Correct Font Family
                      fontWeight: FontWeight.w600, // ✅ Weight 500
                      fontSize: 16, // ✅ Font Size 16px
                      height: 1.0, // ✅ Line Height 16px (16 * 1.0 = 16)
                      letterSpacing: 0.0, // ✅ No letter spacing
                      color: AppColors.darkGreyBackground, // ✅ Text color
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Members Grid
                  _buildMembersGrid(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 🔹 Create Button with correct width & bottom spacing
          Padding(
            padding: const EdgeInsets.only(bottom: 20), // ✅ Adds space from bottom
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85, // ✅ Button takes 85% width
              child: ElevatedButton(
                onPressed: () {
                    String? errorMessage;

                    // 🔹 Validate Inputs
                    if (_groupName.isEmpty) {
                      errorMessage = "✏️ Please enter a group name before creating!";
                    } else if (invitedUserIds.isEmpty) {
                      errorMessage = "👥 Invite members before creating a group!";
                    } else if (invitedUserIds.length < 2) {
                      errorMessage = "👥 A group must have at least 2 members!";
                    }

                    // 🔹 Show error message if any validation fails
                    if (errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            errorMessage,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                          ),
                          backgroundColor: Colors.redAccent, // ✅ Error color
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      return; // ✅ Stop execution
                    }

                    // ✅ If invited users exist, show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "🎉 Group '$_groupName' created successfully!", // ✅ Dynamic group name
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                        ),
                        backgroundColor: Colors.green, // ✅ Success color
                        duration: const Duration(seconds: 2),
                      ),
                    );

                    // ✅ Proceed with group creation (API call, navigation, etc.)
                    print("✅ Creating Group: $_groupName with members: $invitedUserIds");
                  },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor, // ✅ Button background matches Figma (#FFFFFF)
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text(
                  "Create",
                  style: TextStyle(
                    fontFamily: 'Poppins', // ✅ Correct Font Family
                    fontWeight: FontWeight.w800, // ✅ Bold (700)
                    fontSize: 16, // ✅ Font Size 16px
                    height: 1.0, // ✅ Line Height 16px
                    letterSpacing: 1.0, // ✅ No letter spacing
                    color: AppColors.white, // ✅ Text color now matches correct Figma color
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // 🔹 Builds the "Group work" and "Team relationship" tags
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightPurpleBackground,
        borderRadius: BorderRadius.circular(20),
      ),
        child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Poppins', 
                fontWeight: FontWeight.w400, // ✅ Regular (400)
                fontSize: 14, // ✅ Font Size 14px
                height: 1.0, // ✅ Matches Line Height 14px
                letterSpacing: 0.0, // ✅ No letter spacing
                color: Color(0xFF000E08), // ✅ Text Color (Same as provided background)
              ),
            ),
          );   
          
          }


void _toggleUserSelection(String userId) {
  setState(() {
    if (invitedUserIds.contains(userId)) {
      invitedUserIds.remove(userId); // ✅ Remove user if already invited
    } else {
      invitedUserIds.add(userId); // ✅ Add user if not invited
    }
  });

  // ✅ Debugging: Print Updated Invited Members
  final invitedMembers = allUsers.where((user) => invitedUserIds.contains(user["id"])).toList();
  print("✅ Updated Invited Members: $invitedMembers");
}

Widget _buildInvitedMembersGrid() {
  final invitedMembers = allUsers.where((user) => invitedUserIds.contains(user["id"])).toList();

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(12),
    ),
    child: invitedMembers.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.group_add, size: 40, color: Colors.grey.shade400), // 👤 Group Add Icon
              const SizedBox(height: 8), // Small Spacing
              Text(
                "Add members to start",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          )
        : Wrap(
            spacing: 16,
            runSpacing: 16,
            children: invitedMembers.map((user) {
              return _buildMemberAvatar(user["id"]!, user["profilePicture"]!);
            }).toList(),
          ),
  );
}




Widget _buildMembersGrid() {
  return Wrap(
    spacing: 16,
    runSpacing: 16,
    children: allUsers.map((user) {
      final userId = user["id"]!;
      final isSelected = invitedUserIds.contains(userId);

      return GestureDetector(
        onTap: () => _toggleUserSelection(userId), // ✅ Fix: Use central method
        child: Stack(
          children: [
            _buildMemberAvatar(userId, user["profilePicture"]!), // ✅ Avatar
            if (isSelected) // ✅ Show tick if selected
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      );
    }).toList(),
  );
}



 Widget _buildMemberAvatar(String userId, String? profilePicture) {
  bool isInvited = invitedUserIds.contains(userId); // ✅ Check if user is invited

  return Stack(
    children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade300, // ✅ Default Background
        backgroundImage: (profilePicture != null && profilePicture.isNotEmpty)
            ? NetworkImage(profilePicture)
            : null, // ✅ Load image if exists
        child: (profilePicture == null || profilePicture.isEmpty)
            ? const Icon(Icons.person, size: 30, color: Colors.white) // ✅ Placeholder Icon
            : null,
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: () {
            _toggleUserSelection(userId); // ✅ Add or Remove user
          },
          child: CircleAvatar(
            radius: 14, // ✅ Increased Size
            backgroundColor: Colors.white,
            child: Icon(
              isInvited ? Icons.close : Icons.add, // ✅ Switch between "❌" and "➕"
              color: Colors.black,
              size: 20, // ✅ Increased Icon Size
            ),
          ),
        ),
      ),
    ],
  );
}

 
}
