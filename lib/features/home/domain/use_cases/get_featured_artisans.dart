import 'package:artisan/export.dart';

class GetFeaturedArtisans {
  final HomeRepository repository;
  GetFeaturedArtisans(this.repository);

  Future<List<ArtisanSummary>> call() => repository.getFeaturedArtisans();
}
