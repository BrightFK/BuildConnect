import 'dart:ui';

import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProfession;
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _serviceAreaController = TextEditingController();
  bool _isLoading = false;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ref.read(getCategoriesProvider).call();
      setState(() => _categories = categories);
    } catch (e) {
      print('❌ Error loading categories: $e');
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

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final user = ref.read(authStateProvider).value;
        if (user == null) {
          context.showSnackBar('User not found', isError: true);
          return;
        }

        final updateData = {
          'profession': _selectedProfession!,
          'bio': _bioController.text.trim(),
          'experienceYears':
              int.tryParse(_experienceController.text.trim()) ?? 0,
          'serviceArea': _serviceAreaController.text.trim(),
        };

        await ref.read(updateProfileProvider).call(user.id, updateData);

        if (mounted) {
          context.showSnackBar('Profile completed successfully!');
          context.go(Routes.dashboard);
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar('Error: $e', isError: true);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F0F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.build, size: 80, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell customers about your skills',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),

                  // Glass card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Profession Dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedProfession,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.card,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelText: 'Profession *',
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                dropdownColor: AppColors.surface,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedProfession = value),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your profession';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Bio
                              TextFormField(
                                controller: _bioController,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.card,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelText: 'Bio *',
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  hintText: 'Tell customers about yourself...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textHint,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a bio';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Years of Experience
                              TextFormField(
                                controller: _experienceController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.card,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelText: 'Years of Experience *',
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  hintText: 'e.g., 5',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textHint,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your experience';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Service Area
                              TextFormField(
                                controller: _serviceAreaController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.card,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelText: 'Service Area *',
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                  hintText: 'e.g., Lagos, Nigeria',
                                  hintStyle: const TextStyle(
                                    color: AppColors.textHint,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your service area';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              if (_isLoading)
                                const LoadingIndicator()
                              else
                                AppButton(
                                  text: 'Complete Profile',
                                  onPressed: _saveProfile,
                                  gradient: true,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
