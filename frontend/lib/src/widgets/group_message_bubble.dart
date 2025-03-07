import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config.dart';

class GroupMessageBubble extends StatelessWidget {
  final String senderName;
  final String senderProfilePic;
  final String message;
  final String? timestamp;
  final bool isMe;

  const GroupMessageBubble({
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

    // Define profile picture radius and gap space
    double profilePicRadius = 22.0;
    double gap = 20.0;

    // Responsive width calculation for name alignment
    double nameLeftMargin = profilePicRadius + gap;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ), // More vertical space
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // For receiver, show the name above the message (not affecting the profile image)
          if (!isMe) // Show name only for the receiver
            Padding(
              padding: EdgeInsets.only(
                left: nameLeftMargin,
                bottom: 4,
              ), // Adjust the left margin here
              child: Text(
                senderName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          // Row to display profile picture and message bubble
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) // Show avatar only for other users (receiver)
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    "${AppConfig.serverIp}$senderProfilePic",
                  ),
                  radius: profilePicRadius,
                ),
              if (!isMe)
                const SizedBox(width: 10), // Space between avatar and message
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Message Bubble
                  Container(
                    padding:
                        message.startsWith("/uploads/media/") ||
                                message.endsWith(".jpg") ||
                                message.endsWith(".png")
                            ? EdgeInsets
                                .zero // No padding for media (images)
                            : const EdgeInsets.all(
                              12,
                            ), // Padding for text messages
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey[200],
                      borderRadius:
                          isMe
                              ? const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight:
                                    Radius
                                        .zero, // No radius on top right for sender
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              )
                              : const BorderRadius.only(
                                topLeft:
                                    Radius
                                        .zero, // No radius on top left for receiver
                                topRight: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child:
                        (message.startsWith("/uploads/media/") ||
                                message.endsWith(".jpg") ||
                                message.endsWith(".png"))
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Keep rounded corners for images
                              child: Image.network(
                                "${AppConfig.serverIp}$message", // Append backend URL
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
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
                  const SizedBox(
                    height: 4,
                  ), // Space between message and timestamp
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formattedTime,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
