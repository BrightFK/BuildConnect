class ArtisanProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final Map<String, dynamic>? location;
  final String profession;
  final String bio;
  final int experienceYears;
  final String serviceArea;
  final double rating;

  ArtisanProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.location,
    required this.profession,
    required this.bio,
    required this.experienceYears,
    required this.serviceArea,
    required this.rating,
  });
}
