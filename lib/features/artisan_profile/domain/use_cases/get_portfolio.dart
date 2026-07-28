import 'package:artisan/export.dart';

class GetPortfolio {
  final ArtisanProfileRepository repository;
  GetPortfolio(this.repository);

  Future<List<PortfolioItem>> call(String artisanId) =>
      repository.getPortfolio(artisanId);
}
