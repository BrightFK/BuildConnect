import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final double iconSize;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 30,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    // If image URL exists and is not empty, show the image
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) => _buildPlaceholder(),
          ),
        ),
      );
    }

    // No image – show grey background with person icon
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, color: Colors.grey[900], size: iconSize),
    );
  }
}
