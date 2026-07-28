import 'package:artisan/export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArtisanProfileRepositoryImpl implements ArtisanProfileRepository {
  final FirebaseFirestore firestore;

  ArtisanProfileRepositoryImpl(this.firestore);

  @override
  Future<ArtisanProfile> getArtisanProfile(String artisanId) async {
    try {
      print('🔍 Fetching artisan profile for ID: $artisanId');

      // 1. Fetch user data
      final userDoc = await firestore.collection('users').doc(artisanId).get();
      print('📄 User doc exists: ${userDoc.exists}');

      if (!userDoc.exists) {
        throw Exception('User not found for ID: $artisanId');
      }

      // 2. Fetch artisan data
      final artisanDoc = await firestore
          .collection('artisans')
          .doc(artisanId)
          .get();
      print('📄 Artisan doc exists: ${artisanDoc.exists}');

      if (!artisanDoc.exists) {
        throw Exception('Artisan not found for ID: $artisanId');
      }

      final userData = userDoc.data()!;
      final artisanData = artisanDoc.data()!;

      print('✅ User data: ${userData.keys}');
      print('✅ Artisan data: ${artisanData.keys}');

      return ArtisanProfile(
        id: artisanId,
        name: userData['name'] ?? 'Unknown',
        email: userData['email'] ?? '',
        phone: userData['phone'] ?? '',
        profileImage: userData['profileImage'],
        location: userData['location'] != null
            ? {
                'lat': (userData['location'] as GeoPoint).latitude,
                'lng': (userData['location'] as GeoPoint).longitude,
              }
            : null,
        profession: artisanData['profession'] ?? '',
        bio: artisanData['bio'] ?? '',
        experienceYears: artisanData['experienceYears'] ?? 0,
        serviceArea: artisanData['serviceArea'] ?? '',
        rating: (artisanData['rating'] ?? 0.0).toDouble(),
      );
    } catch (e) {
      print('❌ Error fetching artisan profile: $e');
      rethrow;
    }
  }

  @override
  Future<List<PortfolioItem>> getPortfolio(String artisanId) async {
    try {
      print('🔍 Fetching portfolio for artisan: $artisanId');

      // Try with ordering first
      try {
        final snapshot = await firestore
            .collection('portfolio')
            .where('artisanId', isEqualTo: artisanId)
            .orderBy('uploadedAt', descending: true)
            .get();

        print('📄 Portfolio count: ${snapshot.docs.length}');

        return snapshot.docs.map((doc) {
          final data = doc.data();
          return PortfolioItem(
            id: doc.id,
            imageUrl: data['imageUrl'] ?? '',
            uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
          );
        }).toList();
      } catch (e) {
        // If ordering fails (no index), try without ordering
        print('⚠️ Ordering failed, trying without order: $e');
        final snapshot = await firestore
            .collection('portfolio')
            .where('artisanId', isEqualTo: artisanId)
            .get();

        print('📄 Portfolio count (no order): ${snapshot.docs.length}');

        return snapshot.docs.map((doc) {
          final data = doc.data();
          return PortfolioItem(
            id: doc.id,
            imageUrl: data['imageUrl'] ?? '',
            uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
          );
        }).toList();
      }
    } catch (e) {
      print('❌ Error fetching portfolio: $e');
      return [];
    }
  }
}
