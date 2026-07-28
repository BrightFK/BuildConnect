class ArtisanProfileDTO {
  final String userId;
  final String profession;
  final String bio;
  final int experienceYears;
  final String serviceArea;
  final double rating;

  ArtisanProfileDTO({
    required this.userId,
    required this.profession,
    required this.bio,
    required this.experienceYears,
    required this.serviceArea,
    required this.rating,
  });

  factory ArtisanProfileDTO.fromMap(Map<String, dynamic> data) {
    return ArtisanProfileDTO(
      userId: data['userId'] ?? '',
      profession: data['profession'] ?? '',
      bio: data['bio'] ?? '',
      experienceYears: data['experienceYears'] ?? 0,
      serviceArea: data['serviceArea'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }
}
