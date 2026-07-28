class Chat {
  final String id;
  final String customerId;
  final String artisanId;
  final String lastMessage;
  final DateTime updatedAt;

  Chat({
    required this.id,
    required this.customerId,
    required this.artisanId,
    required this.lastMessage,
    required this.updatedAt,
  });
}
