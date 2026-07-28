import 'dart:io';

import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _profileImageUrl = user.profileImage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      try {
        final user = ref.read(authStateProvider).value;
        if (user == null) return;

        final storage = ref.read(storageProvider);
        final refStorage = storage.ref().child('profile/${user.id}.jpg');
        await refStorage.putFile(File(picked.path));
        final url = await refStorage.getDownloadURL();

        setState(() => _profileImageUrl = url);
        context.showSnackBar('Profile picture updated!');
      } catch (e) {
        context.showSnackBar('Error uploading image: $e', isError: true);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = ref.read(authStateProvider).value;
        if (user == null) return;

        final updateData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'profileImage': _profileImageUrl,
        };

        await ref.read(updateProfileProvider).call(user.id, updateData);
        context.showSnackBar('Profile updated successfully!');
        setState(() => _isEditing = false);
        ref.refresh(authStateProvider);
      } catch (e) {
        context.showSnackBar('Error: $e', isError: true);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final isArtisan = user?.role == 'artisan';

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please login',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Styled Cover Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  if (_isEditing) {
                    // Cancel editing
                    _loadUserData();
                    setState(() => _isEditing = false);
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
              ),
            ],
            backgroundColor: AppColors.surface.withOpacity(0.8),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image with Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.secondary.withOpacity(0.8),
                          AppColors.primary.withOpacity(0.6),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 40,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profile Section
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ProfileAvatar(
                          imageUrl: _profileImageUrl,
                          name: user.name,
                          radius: 60,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isArtisan ? 'Artisan' : 'Customer',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        if (isArtisan) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.green,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Verified Artisan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Row (for artisans)
                if (isArtisan) ...[
                  _buildStatsRow(),
                  const SizedBox(height: 16),
                ],

                // Profile Details Card
                _buildProfileCard(user, isArtisan),
                const SizedBox(height: 16),

                // Settings
                _buildSettingsCard(),
                const SizedBox(height: 16),

                // Logout Button
                _buildLogoutCard(),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final user = ref.read(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: ref.read(getDashboardDataProvider).call(user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            children: [
              _buildStatItem('0', 'Portfolio', Icons.photo_library),
              _buildStatItem('0', 'Chats', Icons.chat),
              _buildStatItem('0', 'Rating', Icons.star),
            ],
          );
        }
        final stats = snapshot.data!;
        return Row(
          children: [
            _buildStatItem(
              stats.portfolioCount.toString(),
              'Portfolio',
              Icons.photo_library,
            ),
            _buildStatItem(stats.chatCount.toString(), 'Chats', Icons.chat),
            _buildStatItem(
              stats.averageRating.toStringAsFixed(1),
              'Rating',
              Icons.star,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(UserEntity user, bool isArtisan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 8),
          if (_isEditing)
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppInput(
                    label: 'Full Name',
                    controller: _nameController,
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Phone Number',
                    controller: _phoneController,
                    validator: Validators.validatePhone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const LoadingIndicator()
                  else
                    AppButton(
                      text: 'Save Changes',
                      onPressed: _saveProfile,
                      gradient: true,
                    ),
                ],
              ),
            )
          else
            Column(
              children: [
                _buildInfoTile('Name', user.name, Icons.person),
                _buildInfoTile('Email', user.email, Icons.email),
                _buildInfoTile('Phone', user.phone, Icons.phone),
                if (isArtisan) ...[
                  Divider(color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 8),
                  FutureBuilder(
                    future: ref
                        .read(firestoreProvider)
                        .collection('artisans')
                        .doc(user.id)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final data = snapshot.data!.data() ?? {};
                      return Column(
                        children: [
                          _buildInfoTile(
                            'Profession',
                            data['profession'] ?? 'Not set',
                            Icons.work,
                          ),
                          _buildInfoTile(
                            'Experience',
                            '${data['experienceYears'] ?? 0} years',
                            Icons.timer,
                          ),
                          _buildInfoTile(
                            'Service Area',
                            data['serviceArea'] ?? 'Not set',
                            Icons.location_on,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Info',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => context.push('/terms-privacy?tab=terms'),
            child: _buildSettingsTile(
              'Terms of Service',
              'Read our terms',
              Icons.gavel,
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/terms-privacy?tab=privacy'),
            child: _buildSettingsTile(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/terms-privacy?tab=about'),
            child: _buildSettingsTile(
              'About & Contact',
              'About the developer',
              Icons.info_outline,
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    Widget trailing,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildLogoutCard() {
    return GestureDetector(
      onTap: _showLogoutDialog,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
              context.go(Routes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
