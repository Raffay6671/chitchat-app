import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import 'dart:convert';

class SocketService with ChangeNotifier {
  io.Socket? _socket;
  Map<String, bool> onlineUsers = {}; // Track online/offline users
  Map<String, Map<String, dynamic>> lastMessages =
      {}; // Store last messages per group/chat
  Map<String, int> unreadMessageCount =
      {}; // Store unread message count per group/chat
  String _currentUserId = ''; // Store the current user ID

  io.Socket? get socket => _socket;

  // Connect to WebSocket - UPDATED to store current user ID
  void connect(String userId, List<String> groupIds) {
    if (_socket != null && _socket!.connected) return;

    // Store current user ID
    _currentUserId = userId;
    print("🔑 Current User ID set to: $_currentUserId");

    _socket = io.io(AppConfig.serverIp, {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint("✅ Socket connected");
      _socket!.emit('join', {"userId": userId, "groupIds": groupIds});
      debugPrint("🔗 Joined rooms: $userId & Groups: ${groupIds.join(', ')}");

      // Fetch last messages and unread message count from SharedPreferences
      _fetchLastMessages();
      _fetchUnreadMessageCount();
    });

    _socket!.onDisconnect((_) {
      debugPrint("❌ Socket disconnected");
    });

    // Listen for online status updates
    _socket!.on('userOnline', (data) {
      final userId = data['userId'];
      onlineUsers[userId] = true;
      notifyListeners();
    });

    _socket!.on('userOffline', (data) {
      final userId = data['userId'];
      onlineUsers[userId] = false;
      notifyListeners();
    });

    // Fetch current online users
    _socket!.emit('getOnlineUsers');
    _socket!.on('onlineUsers', (data) {
      onlineUsers = Map.fromIterable(
        data,
        key: (userId) => userId,
        value: (_) => true,
      );
      notifyListeners();
    });
  }

  // Fetch last messages from local storage
  Future<void> _fetchLastMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastMessagesStr = prefs.getString('lastMessages');

      if (lastMessagesStr != null && lastMessagesStr.isNotEmpty) {
        final Map<String, dynamic> decodedMap = jsonDecode(lastMessagesStr);
        lastMessages = Map<String, Map<String, dynamic>>.from(
          decodedMap.map(
            (key, value) => MapEntry(key, Map<String, dynamic>.from(value)),
          ),
        );
        print('✅ Last messages fetched successfully: $lastMessages');
      } else {
        print('⚠️ No last messages found in local storage');
        lastMessages = {};
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching last messages: $e');
      lastMessages = {};
      notifyListeners();
    }
  }

  // Fetch unread message count from local storage
  Future<void> _fetchUnreadMessageCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unreadCountStr = prefs.getString('unreadMessageCount');

      if (unreadCountStr != null && unreadCountStr.isNotEmpty) {
        final Map<String, dynamic> decodedMap = jsonDecode(unreadCountStr);
        unreadMessageCount = Map<String, int>.from(decodedMap);
        print(
          '✅ Unread message count fetched successfully: $unreadMessageCount',
        );
      } else {
        print('⚠️ No unread message count found in local storage');
        unreadMessageCount = {};
      }
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching unread count: $e');
      unreadMessageCount = {};
      notifyListeners();
    }
  }

  // Listen for messages
  void listenForMessages(Function(Map<String, dynamic>) onMessageReceived) {
    _socket?.off('receiveMessage');
    _socket?.on('receiveMessage', (data) {
      debugPrint(
        '📩 Private Message Received: ${data['message']} from ${data['senderId']}',
      );

      // Call _handlePrivateMessage to process the received private message
      _handlePrivateMessage(data);
      onMessageReceived(data);
    });
    debugPrint("✅ Private message listener attached");
  }

  Future<void> _storeUnreadCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'unreadMessageCount',
        jsonEncode(unreadMessageCount),
      );
      print(
        '✅ Stored unread message count in local storage: $unreadMessageCount',
      );
    } catch (e) {
      print('❌ Error storing unread count: $e');
    }
  }

  // Handle group message - UPDATED to check sender ID
  void _handleGroupMessage(Map<String, dynamic> data) {
    final groupId = data['groupId'];
    final message = data['content'];
    final senderId = data['senderId'];
    final timestamp = DateTime.now().toString();

    print('Received group message for groupId $groupId: $message');

    // Store the last unread message for this group
    lastMessages[groupId] = {'message': message, 'timestamp': timestamp};

    // Increment the unread message count for this group, but not for the sender
    if (senderId != _currentUserId) {
      unreadMessageCount[groupId] = (unreadMessageCount[groupId] ?? 0) + 1;
    }

    // Save to local storage
    _storeLastMessages();
    _storeUnreadCount();
    notifyListeners();
  }

  String getChatId(String user1, String user2) {
    // Sort the IDs to ensure consistency regardless of who is sender/receiver
    final sortedIds = [user1, user2]..sort();
    return "${sortedIds[0]}_${sortedIds[1]}";
  }

  // Modify the _handlePrivateMessage method
  // Modify the _handlePrivateMessage method
  void _handlePrivateMessage(Map<String, dynamic> data) {
    final senderId = data['senderId'];
    final message = data['message'];
    final timestamp = DateTime.now().toString();

    // Create a consistent chat ID for this conversation
    final chatId = getChatId(senderId, _currentUserId);

    // Store the message under the chatId for P2P
    lastMessages[chatId] = {'message': message, 'timestamp': timestamp};
    lastMessages[senderId] = {
      'message': message,
      'timestamp': timestamp,
    }; // Backward compatibility

    // Increment unread count only if the message is from someone else
    if (senderId != _currentUserId) {
      unreadMessageCount[chatId] = (unreadMessageCount[chatId] ?? 0) + 1;
    }

    // Save to local storage
    _storeLastMessages();
    _storeUnreadCount();
    notifyListeners();
  }

  Future<void> _storeLastMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedData = jsonEncode(lastMessages);
      await prefs.setString('lastMessages', encodedData);
      print('✅ Stored last messages in local storage');
    } catch (e) {
      print('❌ Error storing last messages: $e');
    }
  }

  // Send message - COMPLETELY REWRITTEN
  void sendMessage(Map<String, dynamic> message) {
    final receiverId = message['receiverId'];
    final messageContent = message['message'];

    // Emit the message to the server
    _socket?.emit('sendMessage', message);

    // Create a consistent chat ID for this conversation
    final chatId = getChatId(_currentUserId, receiverId);

    // Update local data for immediate UI feedback
    final timestamp = DateTime.now().toString();

    // Store the message under both chatId and receiverId (for backward compatibility)
    lastMessages[chatId] = {
      'message': messageContent,
      'timestamp': timestamp,
      'isFromCurrentUser': true,
    };

    lastMessages[receiverId] = {
      'message': messageContent,
      'timestamp': timestamp,
      'isFromCurrentUser': true,
    };

    // Reset unread count for both IDs
    unreadMessageCount[chatId] = 0;
    unreadMessageCount[receiverId] = 0;

    // Save to local storage
    _storeLastMessages();
    _storeUnreadCount();

    // Update UI
    notifyListeners();
  }

  // Listen for group messages
  void listenForGroupMessages(
    Function(Map<String, dynamic>) onGroupMessageReceived,
  ) {
    _socket?.off('receiveGroupMessage');
    _socket?.on('receiveGroupMessage', (data) {
      debugPrint(
        '👥 📩 Group Message Received: ${data['content']} from ${data['senderId']} in group ${data['groupId']}',
      );

      // Call _handleGroupMessage to process the received group message
      _handleGroupMessage(data);
      onGroupMessageReceived(data);
    });
    debugPrint("✅ Group message listener attached");
  }

  void resetUnreadCount(String id) {
    // Check if the unread count is greater than 0 and ensure it is not null
    if ((unreadMessageCount[id] ?? 0) > 0) {
      unreadMessageCount[id] = 0; // Reset unread count for the specific ID

      // If this is a user ID, also reset the chat ID if it exists
      if (id.contains("_")) {
        // This is already a chat ID, no additional reset needed
      } else {
        // This might be a user ID, try to find and reset any chat IDs containing this user
        final keysToReset =
            unreadMessageCount.keys
                .where((key) => key.contains(id) && key.contains("_"))
                .toList();

        for (final key in keysToReset) {
          unreadMessageCount[key] = 0;
        }
      }

      _storeUnreadCount(); // Store updated unread count in SharedPreferences
      notifyListeners(); // Notify listeners to update UI
    }
  }

  // Send group message - COMPLETELY REWRITTEN
  void sendGroupMessage(String groupId, Map<String, dynamic> message) {
    final messageContent = message['content'];

    // Add groupId to the message object
    final messageWithGroup = {...message, "groupId": groupId};

    // Emit the message to the server
    _socket?.emit('sendGroupMessage', messageWithGroup);
    debugPrint(
      "📤 Sent Group Message to server: $messageContent to Group: $groupId",
    );

    // Update local data for immediate UI feedback
    final timestamp = DateTime.now().toString();

    // Store the message in lastMessages map
    lastMessages[groupId] = {
      'message': messageContent,
      'timestamp': timestamp,
      'isFromCurrentUser':
          true, // Add a flag to identify messages sent by current user
    };

    // Ensure the unread count is 0 for the sender's view of this group
    unreadMessageCount[groupId] = 0;

    // Save to local storage
    _storeLastMessages();
    _storeUnreadCount();

    // Update UI
    notifyListeners();
  }

  void leaveChat(String id) {
    resetUnreadCount(id); // Reset unread count when leaving the chat
  }

  // Remove group listeners
  void removeGroupListeners() {
    _socket?.off('receiveGroupMessage');
    debugPrint("🚀 Removed previous group message listener");
  }

  // Join a group
  void joinGroup(String groupId) {
    _socket?.emit('joinGroup', {"groupId": groupId});
    debugPrint("🔗 Joined new group room: $groupId");
  }

  void fetchGroupMembers(
    String groupId,
    Function(int, int) onMembersReceived,
    bool mounted,
  ) {
    print("Requesting members for groupId: $groupId");

    _socket?.emit('getGroupMembers', {"groupId": groupId});

    _socket?.on('groupMembers', (data) {
      print("Received group members data: $data");

      int totalMembers = data['totalMembers'];
      int onlineMembers = data['onlineMembers'];

      debugPrint(
        "👥 Group Members Updated: $totalMembers total, $onlineMembers online",
      );

      if (mounted) {
        onMembersReceived(totalMembers, onlineMembers);
      }
    });
  }

  // Disconnect from socket
  void disconnect() {
    _socket?.disconnect();
    debugPrint("🚪 Socket disconnected");
  }

  // Fetch online status of a user
  bool isUserOnline(String userId) {
    return onlineUsers[userId] ?? false;
  }

  // Debug method to see all stored data
  void debugPrintAllData() {
    print("-------- DEBUG: SOCKET SERVICE DATA --------");
    print("Current User ID: $_currentUserId");
    print("Last Messages: $lastMessages");
    print("Unread Message Count: $unreadMessageCount");
    print("Online Users: $onlineUsers");
    print("----------------------------------------");
  }
}
