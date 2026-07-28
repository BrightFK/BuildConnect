import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchResultsScreen extends ConsumerWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchProvider(query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Results for "$query"'),
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
      ),
      body: searchAsync.when(
        data: (artisans) {
          if (artisans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No artisans found for "$query"',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search terms',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: artisans.length,
            itemBuilder: (context, index) {
              final artisan = artisans[index];
              return _buildArtisanCard(context, artisan);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(searchProvider(query)),
        ),
      ),
    );
  }

  Widget _buildArtisanCard(BuildContext context, ArtisanSummary artisan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ProfileAvatar(
          imageUrl: artisan.profileImage,
          name: artisan.name,
          radius: 30,
        ),
        title: Text(
          artisan.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artisan.profession,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  artisan.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RatingStars(rating: artisan.rating, size: 14),
            const SizedBox(height: 2),
            Text(
              artisan.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        onTap: () => context.push(
          '${Routes.artisanProfile.replaceFirst(':id', artisan.id)}',
        ),
      ),
    );
  }
}
