import 'package:artisan/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    ref.watch(firestoreProvider),
    ref.watch(storageProvider),
  );
});

// Use Case Providers
final getDashboardDataProvider = Provider<GetDashboardData>((ref) {
  return GetDashboardData(ref.watch(dashboardRepositoryProvider));
});

final updateProfileProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(dashboardRepositoryProvider));
});

final uploadPortfolioProvider = Provider<UploadPortfolio>((ref) {
  return UploadPortfolio(ref.watch(dashboardRepositoryProvider));
});

// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider.family<DashboardStats, String>((
  ref,
  artisanId,
) {
  return ref.watch(getDashboardDataProvider).call(artisanId);
});
