import 'dart:io';

import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _professionController;
  late TextEditingController _bioController;
  late TextEditingController _experienceController;
  late TextEditingController _serviceAreaController;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _isImageUploading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _profileImageUrl = user?.profileImage;
    _loadCategories();
    _loadArtisanData();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(getCategoriesProvider).call();
      setState(() => _categories = categories);
    } catch (e) {
      // Use default categories if provider fails
      setState(
        () => _categories = [
          'Electrician',
          'Plumber',
          'Mechanic',
          'Carpenter',
          'Painter',
          'Welder',
          'AC Technician',
          'Tiler',
          'Bricklayer',
          'POP Installer',
        ],
      );
    }
  }

  Future<void> _loadArtisanData() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    try {
      final doc = await ref
          .read(firestoreProvider)
          .collection('artisans')
          .doc(user.id)
          .get();
      final data = doc.data() ?? {};
      setState(() {
        _professionController = TextEditingController(
          text: data['profession'] ?? '',
        );
        _bioController = TextEditingController(text: data['bio'] ?? '');
        _experienceController = TextEditingController(
          text: (data['experienceYears'] ?? 0).toString(),
        );
        _serviceAreaController = TextEditingController(
          text: data['serviceArea'] ?? '',
        );
      });
    } catch (e) {
      print('❌ Error loading artisan data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    _experienceController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _isImageUploading = true);
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
      } finally {
        setState(() => _isImageUploading = false);
      }
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = ref.read(authStateProvider).value;
        if (user == null) {
          context.showSnackBar('User not found', isError: true);
          return;
        }

        final updateData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'profileImage': _profileImageUrl,
          'profession': _professionController.text.trim(),
          'bio': _bioController.text.trim(),
          'experienceYears':
              int.tryParse(_experienceController.text.trim()) ?? 0,
          'serviceArea': _serviceAreaController.text.trim(),
        };

        await ref.read(updateProfileProvider).call(user.id, updateData);

        // Show success message
        context.showSnackBar('Profile updated successfully!');

        // ✅ Navigate back to dashboard
        if (mounted) {
          context.go(Routes.dashboard);
        }
      } catch (e) {
        context.showSnackBar('Error: $e', isError: true);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              _loadArtisanData();
              context.showSnackBar('Refreshed!');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Profile Image with edit button
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                _profileImageUrl != null &&
                                    _profileImageUrl!.isNotEmpty
                                ? NetworkImage(_profileImageUrl!)
                                : null,
                            backgroundColor: AppColors.card,
                            child:
                                _profileImageUrl == null ||
                                    _profileImageUrl!.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.textSecondary,
                                  )
                                : null,
                          ),
                          if (_isImageUploading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          else
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Name
                    AppInput(
                      label: 'Full Name',
                      controller: _nameController,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    AppInput(
                      label: 'Phone Number',
                      controller: _phoneController,
                      validator: Validators.validatePhone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Profession Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _professionController.text.isNotEmpty
                            ? _professionController.text
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Profession',
                          labelStyle: TextStyle(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        hint: const Text(
                          'Select your profession',
                          style: TextStyle(color: AppColors.textHint),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _professionController.text = value ?? '';
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    AppInput(
                      label: 'Bio',
                      controller: _bioController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Years of Experience
                    AppInput(
                      label: 'Years of Experience',
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Service Area
                    AppInput(
                      label: 'Service Area',
                      controller: _serviceAreaController,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    AppButton(
                      text: 'Save Changes',
                      onPressed: _save,
                      gradient: true,
                    ),

                    const SizedBox(height: 12),

                    // Cancel Button
                    AppButton(
                      text: 'Cancel',
                      onPressed: () {
                        context.go(Routes.dashboard);
                      },
                      isOutlined: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
