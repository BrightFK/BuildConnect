import 'package:artisan/export.dart';

class SendMessage {
  final ChatRepository repository;
  SendMessage(this.repository);

  Future<void> call(String chatId, String senderId, String message) {
    return repository.sendMessage(chatId, senderId, message);
  }
}
