import 'package:artisan/export.dart';

class GetChats {
  final ChatRepository repository;
  GetChats(this.repository);

  Future<List<Chat>> call(String userId) => repository.getChats(userId);
}
