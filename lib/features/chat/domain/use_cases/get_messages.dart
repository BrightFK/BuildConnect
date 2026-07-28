import 'package:artisan/export.dart';

class GetMessages {
  final ChatRepository repository;
  GetMessages(this.repository);

  Stream<List<Message>> call(String chatId) => repository.getMessages(chatId);
}
