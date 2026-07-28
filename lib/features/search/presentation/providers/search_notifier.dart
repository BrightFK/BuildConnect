import 'package:artisan/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final searchProvider = FutureProvider.family<List<ArtisanSummary>, String>((
  ref,
  query,
) async {
  if (query.trim().isEmpty) return [];

  final firestore = ref.read(firestoreProvider);
  final searchQuery = query.toLowerCase().trim();

  try {
    // Get all artisans
    final artisansSnapshot = await firestore.collection('artisans').get();
    final List<ArtisanSummary> results = [];

    for (final doc in artisansSnapshot.docs) {
      final artisanData = doc.data();
      final artisanId = doc.id;

      // Get user data
      final userDoc = await firestore.collection('users').doc(artisanId).get();
      if (!userDoc.exists) continue;

      final userData = userDoc.data()!;
      final name = (userData['name'] ?? '').toLowerCase();
      final profession = (artisanData['profession'] ?? '').toLowerCase();
      final serviceArea = (artisanData['serviceArea'] ?? '').toLowerCase();

      // Check if search query matches any field
      if (name.contains(searchQuery) ||
          profession.contains(searchQuery) ||
          serviceArea.contains(searchQuery)) {
        results.add(
          ArtisanSummary(
            id: artisanId,
            name: userData['name'] ?? 'Unknown',
            profession: artisanData['profession'] ?? '',
            profileImage: userData['profileImage'] ?? '',
            rating: (artisanData['rating'] ?? 0.0).toDouble(),
            location: artisanData['serviceArea'] ?? '',
          ),
        );
      }
    }

    return results;
  } catch (e) {
    print('❌ Search error: $e');
    return [];
  }
});
