import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupMessageBubble extends StatelessWidget {
  final String senderName;
  final String senderProfilePic;
  final String message;
  final String? timestamp;
  final bool isMe;

  const GroupMessageBubble({
    Key? key,
    required this.senderName,
    required this.senderProfilePic,
    required this.message,
    required this.timestamp,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Handle null timestamps
    DateTime? dateTime;
    if (timestamp != null) {
      try {
        dateTime =
            DateTime.parse(timestamp!).toLocal(); // ✅ Convert to local timezone
      } catch (e) {
        print("❌ Error parsing timestamp: $timestamp");
      }
    }

    // ✅ Format timestamp as "9:01 AM"
    String formattedTime =
        dateTime != null ? DateFormat('h:mm a').format(dateTime) : "Unknown";

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ), // ✅ More vertical space
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) // ✅ Show name only for other users
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 6),
              child: Text(
                senderName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMe) // ✅ Show avatar only for other users
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    "http://10.10.20.5:5000$senderProfilePic",
                  ),
                  radius: 22,
                ),
              if (!isMe)
                const SizedBox(width: 10), // ✅ Space between avatar and message
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blueAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width *
                          0.75, // ✅ Responsive width
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ), // ✅ Space between message and timestamp
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      formattedTime,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
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
