import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  io.Socket? _socket;

  // Connect once at login
  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io('http://10.10.20.5:5000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint("✅ Socket connected");
      _socket!.emit('join', userId);
      debugPrint("🔗 Joined room: $userId");
    });

    _socket!.onDisconnect((_) {
      debugPrint("❌ Socket disconnected");
    });
  }

  // Listen for messages ONCE (in login screen)
  void listenForMessages(Function(Map<String, dynamic>) onMessageReceived) {
    // remove old listeners
    _socket?.off('receiveMessage');
    _socket?.on('receiveMessage', (data) {
      debugPrint('📩 Live Message: ${data['message']}');
      onMessageReceived(data);
    });
    debugPrint("✅ Global message listener attached");
  }

  void sendMessage(Map<String, dynamic> message) {
    _socket?.emit('sendMessage', message);
  }

  void disconnect() {
    _socket?.disconnect();
    debugPrint("🚪 Socket disconnected");
  }
}
