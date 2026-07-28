import 'package:artisan/export.dart';

class GetDashboardData {
  final DashboardRepository repository;
  GetDashboardData(this.repository);

  Future<DashboardStats> call(String artisanId) =>
      repository.getDashboardStats(artisanId);
}
