import 'package:artisan/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(ref.watch(firestoreProvider));
});

final getFeaturedArtisansProvider = Provider<GetFeaturedArtisans>((ref) {
  return GetFeaturedArtisans(ref.watch(homeRepositoryProvider));
});

final getCategoriesProvider = Provider<GetCategories>((ref) {
  return GetCategories(ref.watch(homeRepositoryProvider));
});

final homeViewModelProvider = FutureProvider<HomeViewModel>((ref) async {
  final featured = await ref.watch(getFeaturedArtisansProvider).call();
  final categories = await ref.watch(getCategoriesProvider).call();
  final recent = await ref
      .watch(getFeaturedArtisansProvider)
      .call(); // reuse for now
  return HomeViewModel(
    featuredArtisans: featured,
    categories: categories,
    recentlyJoined: recent,
  );
});

class HomeViewModel {
  final List<ArtisanSummary> featuredArtisans;
  final List<String> categories;
  final List<ArtisanSummary> recentlyJoined;

  HomeViewModel({
    required this.featuredArtisans,
    required this.categories,
    required this.recentlyJoined,
  });
}
