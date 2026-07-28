import 'package:artisan/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
final artisanProfileRepositoryProvider = Provider<ArtisanProfileRepository>((
  ref,
) {
  return ArtisanProfileRepositoryImpl(ref.watch(firestoreProvider));
});

// Use Case Providers
final getArtisanProfileProvider = Provider<GetArtisanProfile>((ref) {
  return GetArtisanProfile(ref.watch(artisanProfileRepositoryProvider));
});

final getPortfolioProvider = Provider<GetPortfolio>((ref) {
  return GetPortfolio(ref.watch(artisanProfileRepositoryProvider));
});

// Profile Provider - for fetching artisan profile
final artisanProfileProvider = FutureProvider.family<ArtisanProfile, String>((
  ref,
  id,
) async {
  try {
    print('🔄 Fetching profile for artisan: $id');
    final profile = await ref.watch(getArtisanProfileProvider).call(id);
    print('✅ Profile fetched successfully');
    return profile;
  } catch (e, stack) {
    print('❌ Profile provider error: $e');
    print('📚 Stack trace: $stack');
    rethrow;
  }
});

// Portfolio Provider - for fetching portfolio images
final portfolioProvider = FutureProvider.family<List<PortfolioItem>, String>((
  ref,
  id,
) async {
  try {
    return await ref.watch(getPortfolioProvider).call(id);
  } catch (e) {
    print('⚠️ Portfolio error (returning empty): $e');
    return [];
  }
});
