class ArtisanCardDTO {
  final String id;
  final String name;
  final String profession;
  final String profileImage;
  final double rating;
  final String location;

  ArtisanCardDTO({
    required this.id,
    required this.name,
    required this.profession,
    required this.profileImage,
    required this.rating,
    required this.location,
  });

  factory ArtisanCardDTO.fromMap(Map<String, dynamic> data, String id) {
    return ArtisanCardDTO(
      id: id,
      name: data['name'] ?? '',
      profession: data['profession'] ?? '',
      profileImage: data['profileImage'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      location: data['serviceArea'] ?? '',
    );
  }
}
