import 'package:artisan/export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtisanProfileScreen extends ConsumerStatefulWidget {
  final String artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  ConsumerState<ArtisanProfileScreen> createState() =>
      _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(artisanProfileProvider(widget.artisanId));
    final portfolioAsync = ref.watch(portfolioProvider(widget.artisanId));
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        data: (profile) {
          return CustomScrollView(
            slivers: [
              // Styled App Bar with gradient
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.surface.withOpacity(0.8),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.secondary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ProfileAvatar(
                            imageUrl: profile.profileImage,
                            name: profile.name,
                            radius: 50,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            profile.profession,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => _shareProfile(context, profile),
                  ),
                ],
              ),

              // Main content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Rating & Location Row
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoChip(
                            icon: Icons.star,
                            label: profile.rating.toStringAsFixed(1),
                            subtitle: 'Rating',
                            color: Colors.amber,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          _buildInfoChip(
                            icon: Icons.work,
                            label: '${profile.experienceYears}+',
                            subtitle: 'Years',
                            color: AppColors.primary,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          _buildInfoChip(
                            icon: Icons.location_on,
                            label: profile.serviceArea,
                            subtitle: 'Location',
                            color: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bio Section
                    _buildSection(
                      title: 'About',
                      icon: Icons.person_outline,
                      child: Text(
                        profile.bio.isEmpty ? 'No bio provided' : profile.bio,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Portfolio Section
                    _buildSection(
                      title: 'Portfolio',
                      icon: Icons.photo_library_outlined,
                      child: portfolioAsync.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No portfolio images yet',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      item.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: AppColors.card,
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.6),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            Formatters.formatDate(
                                              item.uploadedAt,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, st) => const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No portfolio available',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Chat',
                            onPressed: () {
                              if (currentUser == null) {
                                context.showSnackBar('Please login first');
                                return;
                              }
                              _startChat(
                                context,
                                ref,
                                widget.artisanId,
                                profile.name,
                              );
                            },
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: 'Call',
                            onPressed: () =>
                                _makePhoneCall(context, profile.phone),
                            gradient: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(artisanProfileProvider(widget.artisanId)),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ---------- Share Function ----------
  void _shareProfile(BuildContext context, ArtisanProfile profile) async {
    final shareLink = Routes.getArtisanShareLink(profile.id);
    final message =
        '''
🏠 Check out ${profile.name} on BuilderConnect!

📌 Profession: ${profile.profession}
⭐ Rating: ${profile.rating}/5.0
📍 Location: ${profile.serviceArea}
💼 Experience: ${profile.experienceYears} years

🔗 View profile: $shareLink

Download BuilderConnect to connect with trusted artisans!
''';

    try {
      await Share.share(
        message,
        subject: '${profile.name} - BuilderConnect Artisan',
      );
    } catch (e) {
      context.showSnackBar('Error sharing: $e', isError: true);
    }
  }

  // ---------- Call Function ----------
  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    if (cleanNumber.isEmpty) {
      context.showSnackBar('Phone number not available', isError: true);
      return;
    }

    final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        await Clipboard.setData(ClipboardData(text: cleanNumber));
        context.showSnackBar('Phone number copied to clipboard!');
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: cleanNumber));
      context.showSnackBar('Phone number copied to clipboard!');
    }
  }

  // ---------- Chat Function ----------
  void _startChat(
    BuildContext context,
    WidgetRef ref,
    String artisanId,
    String artisanName,
  ) async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) {
      context.showSnackBar('Please login first');
      return;
    }

    // Prevent chatting with yourself
    if (currentUser.id == artisanId) {
      context.showSnackBar('You cannot chat with yourself');
      return;
    }

    try {
      final firestore = ref.read(firestoreProvider);

      // Check if chat already exists
      final snapshot = await firestore
          .collection('chats')
          .where('customerId', isEqualTo: currentUser.id)
          .where('artisanId', isEqualTo: artisanId)
          .get();

      String chatId;
      if (snapshot.docs.isNotEmpty) {
        chatId = snapshot.docs.first.id;
      } else {
        // Create new chat
        final docRef = firestore.collection('chats').doc();
        await docRef.set({
          'customerId': currentUser.id,
          'artisanId': artisanId,
          'lastMessage': '',
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
        chatId = docRef.id;
      }

      // Navigate to chat
      if (mounted) {
        context.push(
          '${Routes.chat.replaceFirst(':chatId', chatId)}?otherUserId=$artisanId',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Error starting chat: $e', isError: true);
      }
    }
  }
}
