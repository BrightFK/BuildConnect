import 'dart:io';

import 'package:artisan/export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  DashboardRepositoryImpl(this.firestore, this.storage);

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(userId).update({
      'name': data['name'],
      'phone': data['phone'],
      'profileImage': data['profileImage'],
    });
    if (data.containsKey('profession') ||
        data.containsKey('bio') ||
        data.containsKey('experienceYears') ||
        data.containsKey('serviceArea')) {
      await firestore.collection('artisans').doc(userId).update({
        'profession': data['profession'],
        'bio': data['bio'],
        'experienceYears': data['experienceYears'],
        'serviceArea': data['serviceArea'],
      });
    }
  }

  @override
  Future<void> uploadPortfolio(String artisanId, XFile image) async {
    final ref = storage.ref().child(
      'portfolio/$artisanId/${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await ref.putFile((await image.readAsBytes()) as File);
    final downloadUrl = await ref.getDownloadURL();
    await firestore.collection('portfolio').add({
      'artisanId': artisanId,
      'imageUrl': downloadUrl,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<DashboardStats> getDashboardStats(String artisanId) async {
    // Portfolio count
    final portfolioSnapshot = await firestore
        .collection('portfolio')
        .where('artisanId', isEqualTo: artisanId)
        .count()
        .get();
    final portfolioCount = portfolioSnapshot.count ?? 0; // ✅ handle null

    // Chat count
    final chatSnapshot = await firestore
        .collection('chats')
        .where('artisanId', isEqualTo: artisanId)
        .count()
        .get();
    final chatCount = chatSnapshot.count ?? 0; // ✅ handle null

    // Rating
    final artisanDoc = await firestore
        .collection('artisans')
        .doc(artisanId)
        .get();
    final rating = (artisanDoc.data()?['rating'] ?? 0.0).toDouble();

    return DashboardStats(
      portfolioCount: portfolioCount,
      chatCount: chatCount,
      averageRating: rating,
    );
  }
}
