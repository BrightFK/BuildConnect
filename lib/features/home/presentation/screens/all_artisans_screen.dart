import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AllArtisansScreen extends ConsumerStatefulWidget {
  final String title;
  final String type; // 'featured' or 'recent'

  const AllArtisansScreen({super.key, required this.title, required this.type});

  @override
  ConsumerState<AllArtisansScreen> createState() => _AllArtisansScreenState();
}

class _AllArtisansScreenState extends ConsumerState<AllArtisansScreen> {
  late Future<List<ArtisanSummary>> _artisans;

  @override
  void initState() {
    super.initState();
    _artisans = _fetchArtisans();
  }

  Future<List<ArtisanSummary>> _fetchArtisans() async {
    final firestore = ref.read(firestoreProvider);
    final List<ArtisanSummary> results = [];

    try {
      // Get all artisans
      final artisansSnapshot = await firestore.collection('artisans').get();

      for (final doc in artisansSnapshot.docs) {
        final artisanData = doc.data();
        final artisanId = doc.id;

        // Get user data
        final userDoc = await firestore
            .collection('users')
            .doc(artisanId)
            .get();
        if (!userDoc.exists) continue;

        final userData = userDoc.data()!;
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

      // Sort based on type
      if (widget.type == 'featured') {
        results.sort((a, b) => b.rating.compareTo(a.rating));
      } else {
        results.sort((a, b) => a.name.compareTo(b.name));
      }

      return results;
    } catch (e) {
      print('❌ Error fetching artisans: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine grid columns based on screen size
    int crossAxisCount;
    double childAspectRatio;
    double cardPadding;
    double avatarRadius;
    double fontSize;
    double spacing;

    if (screenWidth < 600) {
      // Mobile
      crossAxisCount = 2;
      childAspectRatio = 0.70;
      cardPadding = 12;
      avatarRadius = 35;
      fontSize = 14;
      spacing = 12;
    } else if (screenWidth < 900) {
      // Tablet
      crossAxisCount = 3;
      childAspectRatio = 0.75;
      cardPadding = 16;
      avatarRadius = 40;
      fontSize = 16;
      spacing = 16;
    } else if (screenWidth < 1200) {
      // Small Desktop
      crossAxisCount = 4;
      childAspectRatio = 0.80;
      cardPadding = 20;
      avatarRadius = 45;
      fontSize = 16;
      spacing = 20;
    } else {
      // Large Desktop
      crossAxisCount = 5;
      childAspectRatio = 0.85;
      cardPadding = 24;
      avatarRadius = 50;
      fontSize = 18;
      spacing = 24;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
      ),
      body: FutureBuilder<List<ArtisanSummary>>(
        future: _artisans,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return ErrorState(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _artisans = _fetchArtisans()),
            );
          }

          final artisans = snapshot.data ?? [];

          if (artisans.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No artisans found',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // ✅ Responsive GridView
          return GridView.builder(
            padding: EdgeInsets.all(spacing),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: artisans.length,
            shrinkWrap: false,
            itemBuilder: (context, index) {
              final artisan = artisans[index];
              return _buildArtisanCard(
                context,
                artisan,
                avatarRadius: avatarRadius,
                fontSize: fontSize,
                padding: cardPadding,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildArtisanCard(
    BuildContext context,
    ArtisanSummary artisan, {
    required double avatarRadius,
    required double fontSize,
    required double padding,
  }) {
    return GestureDetector(
      onTap: () => context.push(
        '${Routes.artisanProfile.replaceFirst(':id', artisan.id)}',
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileAvatar(
                imageUrl: artisan.profileImage,
                name: artisan.name,
                radius: avatarRadius,
              ),
              SizedBox(height: padding * 0.6),
              Text(
                artisan.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: fontSize,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                artisan.profession,
                style: TextStyle(
                  fontSize: fontSize * 0.75,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: padding * 0.3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingStars(rating: artisan.rating, size: fontSize * 0.75),
                  SizedBox(width: padding * 0.3),
                  Text(
                    artisan.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: fontSize * 0.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: padding * 0.4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: padding * 0.5,
                  vertical: padding * 0.2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: fontSize * 0.6,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: padding * 0.2),
                    Text(
                      artisan.location,
                      style: TextStyle(
                        fontSize: fontSize * 0.6,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
