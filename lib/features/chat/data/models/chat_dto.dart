import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDTO {
  final String id;
  final String customerId;
  final String artisanId;
  final String lastMessage;
  final DateTime updatedAt;

  ChatDTO({
    required this.id,
    required this.customerId,
    required this.artisanId,
    required this.lastMessage,
    required this.updatedAt,
  });

  factory ChatDTO.fromMap(Map<String, dynamic> data, String id) {
    return ChatDTO(
      id: id,
      customerId: data['customerId'] ?? '',
      artisanId: data['artisanId'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
