import 'package:cloud_firestore/cloud_firestore.dart';

class MessageDTO {
  final String id;
  final String chatId;
  final String senderId;
  final String message;
  final DateTime timestamp;

  MessageDTO({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  factory MessageDTO.fromMap(Map<String, dynamic> data, String id) {
    return MessageDTO(
      id: id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
