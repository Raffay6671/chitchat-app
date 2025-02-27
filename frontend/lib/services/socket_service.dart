import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/material.dart';

class SocketService with ChangeNotifier {
  io.Socket? _socket;
  io.Socket? get socket => _socket;

  // ✅ Connect to the Socket.io server
  // userId must be non-null, so ensure your app logic guarantees that
  void connect(String userId) {
    _socket = io.io('http://10.10.20.5:5000', {
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint("✅ Connected to Socket.IO Server");
      // Join the room named by this user’s ID
      _socket!.emit('join', userId);
    });

    _socket!.onDisconnect((_) {
      debugPrint("❌ Disconnected from Socket.IO Server");
    });

    notifyListeners();
  }

  // ✅ Send a message
  void sendMessage(Map<String, dynamic> message) {
    _socket?.emit('sendMessage', message);
  }

  // ✅ Listen for messages
  void listenForMessages(Function(Map<String, dynamic>) onMessageReceived) {
    _socket?.on('receiveMessage', (data) {
      onMessageReceived(data);
    });
  }

  // ✅ Disconnect socket
  void disconnect() {
    _socket?.disconnect();
  }
}
