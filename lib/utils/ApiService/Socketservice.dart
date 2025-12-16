import 'dart:async';
import 'package:Ebozor/ui/screens/chat/chat_audio/widgets/chat_widget.dart';
import 'package:Ebozor/utils/notification/chat_message_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:Ebozor/utils/LocalStoreage/hive_utils.dart';

class ChatSocketService {
  // Singleton instance
  static final ChatSocketService _instance = ChatSocketService._internal();
  factory ChatSocketService() => _instance;
  ChatSocketService._internal();

  IO.Socket? _socket;
  Timer? _presenceTimer;

  bool get isConnected => _socket?.connected ?? false;

  // Connect socket safely
  void connect() {
    if (isConnected) return; // Prevent duplicate connections

    _socket = IO.io(
      "http://143.110.251.34:6002",
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({"token": "Bearer ${HiveUtils.getJWT()}"})
          .build(),
    );

    _socket!.onConnect((_) {
      print("🔥 Socket Connected");
      _startPresencePing();
    });

    _socket!.onDisconnect((_) {
      print("🔥 Socket Disconnected");
      _stopPresencePing();
    });

    // Listen to messages once
    _socket!.on("message", _onMessageReceived);

    _socket!.connect();
  }

  // Handle incoming messages
  void _onMessageReceived(dynamic data) {
    final senderId = data['sender_id'].toString();
    final myId = HiveUtils.getUserId();

    // Ignore own messages
    if (senderId == myId) {
      print("🔥 Ignored own message");
      return;
    }

    final chat = ChatMessage(
      key: ValueKey(data['id']),
      message: data['message'] ?? "",
      senderId: int.parse(senderId),
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
      itemOfferId: data['item_offer_id'],
      file: data['file'] ?? "",
      audio: data['audio'] ?? "",
    );

    ChatMessageHandler.add(chat);
  }

  void joinOffer(int offerId) {
    if (!isConnected) connect();
    print("🔥 Emitting join: {offerId: $offerId}");
    _socket?.emit("join", {"offerId": offerId});
  }

  void sendMessage(int offerId, String message) {
    print("🔥 Emitting message: {offerId: $offerId, message: $message}");
    _socket?.emit("message", {
      "offerId": offerId,
      "message": message,
    });
  }

  void typingStart(int offerId) {
    _socket?.emit("typing:start", {"offerId": offerId});
  }

  void typingStop(int offerId) {
    _socket?.emit("typing:stop", {"offerId": offerId});
  }

  void _startPresencePing() {
    _presenceTimer?.cancel();
    _presenceTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      print("🔥 Emitting presence:ping");
      _socket?.emit("presence:ping");
    });
  }

  void _stopPresencePing() {
    _presenceTimer?.cancel();
  }

  void disconnect() {
    _stopPresencePing();
    _socket?.disconnect();
    _socket = null;
  }
}
