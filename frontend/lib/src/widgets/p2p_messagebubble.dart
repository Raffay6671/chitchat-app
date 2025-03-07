import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config.dart';

class P2PMessageBubble extends StatelessWidget {
  final String senderName;
  final String senderProfilePic;
  final String message;
  final String? timestamp;
  final bool isMe;

  const P2PMessageBubble({
    super.key,
    required this.senderName,
    required this.senderProfilePic,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null timestamps
    DateTime? dateTime;
    if (timestamp != null) {
      try {
        dateTime =
            DateTime.parse(timestamp!).toLocal(); // Convert to local timezone
      } catch (e) {
        print("❌ Error parsing timestamp: $timestamp");
      }
    }

    // Format timestamp as "9:01 AM"
    String formattedTime =
        dateTime != null ? DateFormat('h:mm a').format(dateTime) : "Unknown";

    // 🔹 Define Bubble Colors
    final Color senderColor = const Color(0xFF3D4A7A); // Sender (Dark Blue)
    final Color receiverColor = const Color(
      0xFFF2F7FB,
    ); // Receiver (Light Greyish Blue)

    // 🔹 Define Border Radius
    BorderRadius senderBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.zero, // Straight
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    BorderRadius receiverBorderRadius = const BorderRadius.only(
      topLeft: Radius.zero, // Straight
      topRight: Radius.circular(16),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(16),
    );

    // ✅ Check if the message is an image or text
    bool isImage =
        message.startsWith("/uploads/media/") ||
        message.endsWith(".jpg") ||
        message.endsWith(".png");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Show Receiver Profile Picture (Only for Receiver)
          if (!isMe)
            CircleAvatar(
              backgroundImage:
                  senderProfilePic.isNotEmpty
                      ? NetworkImage("${AppConfig.serverIp}$senderProfilePic")
                      : const AssetImage("assets/default_profile.png")
                          as ImageProvider,
              radius: 22,
              backgroundColor: Colors.grey[300],
            ),

          if (!isMe) const SizedBox(width: 10),

          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) // Show sender name above message (for receiver only)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    senderName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',

                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

              // ✅ Message Bubble (Text or Image)
              Container(
                padding:
                    isImage
                        ? EdgeInsets.zero
                        : const EdgeInsets.all(12), // ✅ No padding for images
                decoration:
                    isImage
                        ? null // ✅ Remove decoration for images
                        : BoxDecoration(
                          color: isMe ? senderColor : receiverColor,
                          borderRadius:
                              isMe ? senderBorderRadius : receiverBorderRadius,
                        ),
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width * 0.75, // Limit width
                ),
                child:
                    isImage
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // ✅ Only round edges for images
                          child: Image.network(
                            "${AppConfig.serverIp}$message",
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                          ),
                        )
                        : Text(
                          message,
                          style: TextStyle(
                            fontFamily: 'Poppins',

                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 12,
                          ),
                        ),
              ),

              const SizedBox(height: 4), // Space between message and timestamp
              // ✅ Timestamp (Align it to the right of the bubble)
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
