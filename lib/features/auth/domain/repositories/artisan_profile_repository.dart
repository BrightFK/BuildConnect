import 'package:artisan/export.dart';

abstract class ArtisanProfileRepository {
  Future<ArtisanProfile> getArtisanProfile(String artisanId);
  Future<List<PortfolioItem>> getPortfolio(String artisanId);
}
