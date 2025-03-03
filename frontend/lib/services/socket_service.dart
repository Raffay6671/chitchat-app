import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  io.Socket? _socket;

  // ✅ Connect to WebSocket with user ID and groups
  void connect(String userId, List<String> groupIds) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io('http://10.10.20.5:5000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint("✅ Socket connected");
      _socket!.emit('join', {
        "userId": userId,
        "groupIds": groupIds,
      }); // ✅ Send groups too
      debugPrint("🔗 Joined rooms: $userId & Groups: ${groupIds.join(', ')}");
    });

    _socket!.onDisconnect((_) {
      debugPrint("❌ Socket disconnected");
    });
  }

  // ✅ Listen for 1-to-1 messages
  void listenForMessages(Function(Map<String, dynamic>) onMessageReceived) {
    _socket?.off('receiveMessage'); // ✅ Ensure no duplicate listeners
    _socket?.on('receiveMessage', (data) {
      debugPrint('📩 Private Message: ${data['message']}');
      onMessageReceived(data);
    });
    debugPrint("✅ Private message listener attached");
  }

  // ✅ Send 1-to-1 message
  void sendMessage(Map<String, dynamic> message) {
    _socket?.emit('sendMessage', message);
  }

  // ✅ Listen for group messages
  void listenForGroupMessages(
    Function(Map<String, dynamic>) onGroupMessageReceived,
  ) {
    _socket?.off('receiveGroupMessage'); // ✅ Ensure no duplicate listeners
    _socket?.on('receiveGroupMessage', (data) {
      debugPrint('👥 📩 Group Message: ${data['content']}');
      onGroupMessageReceived(data);
    });
    debugPrint("✅ Group message listener attached");
  }

  // ✅ Send group message
  void sendGroupMessage(String groupId, Map<String, dynamic> message) {
    final messageWithGroup = {
      ...message,
      "groupId": groupId, // ✅ Ensure groupId is attached
    };
    _socket?.emit('sendGroupMessage', messageWithGroup);
    debugPrint(
      "📤 Sent Group Message: ${message['content']} to Group: $groupId",
    );
  }

  void removeGroupListeners() {
    _socket?.off('receiveGroupMessage');
    debugPrint("🚀 Removed previous group message listener");
  }

  void joinGroup(String groupId) {
    // Emit a new event so that the socket joins the new group room
    _socket?.emit('joinGroup', {"groupId": groupId});
    debugPrint("🔗 Joined new group room: $groupId");
  }

  // ✅ Disconnect from socket
  void disconnect() {
    _socket?.disconnect();
    debugPrint("🚪 Socket disconnected");
  }
}
