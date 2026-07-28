import 'package:artisan/export.dart';

class UpdateProfile {
  final DashboardRepository repository;
  UpdateProfile(this.repository);

  Future<void> call(String userId, Map<String, dynamic> data) =>
      repository.updateProfile(userId, data);
}
