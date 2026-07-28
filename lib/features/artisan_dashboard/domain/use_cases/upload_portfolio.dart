import 'package:artisan/export.dart';
import 'package:image_picker/image_picker.dart';

class UploadPortfolio {
  final DashboardRepository repository;
  UploadPortfolio(this.repository);

  Future<void> call(String artisanId, XFile image) =>
      repository.uploadPortfolio(artisanId, image);
}
