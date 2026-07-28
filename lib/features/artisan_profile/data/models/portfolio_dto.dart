import 'package:cloud_firestore/cloud_firestore.dart';

class PortfolioDTO {
  final String id;
  final String imageUrl;
  final DateTime uploadedAt;

  PortfolioDTO({
    required this.id,
    required this.imageUrl,
    required this.uploadedAt,
  });

  factory PortfolioDTO.fromMap(Map<String, dynamic> data, String id) {
    return PortfolioDTO(
      id: id,
      imageUrl: data['imageUrl'] ?? '',
      uploadedAt:
          (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
