import 'package:artisan/export.dart';

abstract class ChatRepository {
  Future<List<Chat>> getChats(String userId);
  Stream<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, String senderId, String message);
}
