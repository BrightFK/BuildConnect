class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String message;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.message,
    required this.timestamp,
  });
}
