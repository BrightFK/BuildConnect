import 'package:artisan/export.dart';

class GetCategories {
  final HomeRepository repository;
  GetCategories(this.repository);

  Future<List<String>> call() => repository.getCategories();
}
