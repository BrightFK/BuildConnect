import 'package:artisan/export.dart';

abstract class HomeRepository {
  Future<List<ArtisanSummary>> getFeaturedArtisans();
  Future<List<ArtisanSummary>> getRecentlyJoined();
  Future<List<String>> getCategories();
}
