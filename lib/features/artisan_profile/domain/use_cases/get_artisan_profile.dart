import 'package:artisan/export.dart';

class GetArtisanProfile {
  final ArtisanProfileRepository repository;
  GetArtisanProfile(this.repository);

  Future<ArtisanProfile> call(String artisanId) =>
      repository.getArtisanProfile(artisanId);
}
