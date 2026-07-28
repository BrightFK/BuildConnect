import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final Map<String, dynamic>? location;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.location,
    required this.createdAt,
  });

  // ✅ Add this factory method
  factory UserEntity.fromMap(Map<String, dynamic> data, String id) {
    // Convert GeoPoint to Map if needed
    final loc = data['location'];
    Map<String, dynamic>? locationMap;
    if (loc != null && loc is GeoPoint) {
      locationMap = {'lat': loc.latitude, 'lng': loc.longitude};
    }
    return UserEntity(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'customer',
      profileImage: data['profileImage'],
      location: locationMap,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
