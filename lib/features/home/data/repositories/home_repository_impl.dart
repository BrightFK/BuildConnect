import 'package:artisan/export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeRepositoryImpl implements HomeRepository {
  final FirebaseFirestore firestore;

  HomeRepositoryImpl(this.firestore);

  @override
  Future<List<ArtisanSummary>> getFeaturedArtisans() async {
    final snapshot = await firestore
        .collection('artisans')
        .orderBy('rating', descending: true)
        .limit(10)
        .get();
    final List<ArtisanSummary> list = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final userDoc = await firestore.collection('users').doc(doc.id).get();
      final userData = userDoc.data() ?? {};
      list.add(
        ArtisanSummary(
          id: doc.id,
          name: userData['name'] ?? '',
          profession: data['profession'] ?? '',
          profileImage: userData['profileImage'] ?? '',
          rating: (data['rating'] ?? 0.0).toDouble(),
          location: data['serviceArea'] ?? '',
        ),
      );
    }
    return list;
  }

  @override
  Future<List<ArtisanSummary>> getRecentlyJoined() async {
    final snapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'artisan')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    final List<ArtisanSummary> list = [];
    for (final doc in snapshot.docs) {
      final userData = doc.data();
      final artisanDoc = await firestore
          .collection('artisans')
          .doc(doc.id)
          .get();
      final artisanData = artisanDoc.data() ?? {};
      list.add(
        ArtisanSummary(
          id: doc.id,
          name: userData['name'] ?? '',
          profession: artisanData['profession'] ?? '',
          profileImage: userData['profileImage'] ?? '',
          rating: (artisanData['rating'] ?? 0.0).toDouble(),
          location: artisanData['serviceArea'] ?? '',
        ),
      );
    }
    return list;
  }

  @override
  Future<List<String>> getCategories() async {
    // Predefined categories
    return [
      'Electrician',
      'Plumber',
      'Mechanic',
      'Carpenter',
      'Painter',
      'Welder',
      'AC Technician',
      'Tiler',
      'Bricklayer',
      'POP Installer',
    ];
  }
}
