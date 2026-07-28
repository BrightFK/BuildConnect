import 'package:artisan/export.dart';
import 'package:image_picker/image_picker.dart';

abstract class DashboardRepository {
  Future<void> updateProfile(String userId, Map<String, dynamic> data);
  Future<void> uploadPortfolio(String artisanId, XFile image);
  Future<DashboardStats> getDashboardStats(String artisanId);
}
