import 'dart:ui';

import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'customer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final authState = ref.read(authNotifierProvider);
        authState.when(
          data: (user) {
            if (user != null) {
              context.showSnackBar('Registration successful!');
              // ✅ Check role and navigate accordingly
              if (_selectedRole == 'artisan') {
                context.go(Routes.completeProfile);
              } else {
                context.go(Routes.home);
              }
            }
          },
          error: (err, stack) {
            context.showSnackBar(err.toString(), isError: true);
          },
          loading: () {},
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

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
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join BuilderConnect',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),

                  // Glassmorphism card
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
                              AppInput(
                                label: 'Full Name',
                                controller: _nameController,
                                validator: Validators.validateName,
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Email',
                                controller: _emailController,
                                validator: Validators.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Phone',
                                controller: _phoneController,
                                validator: Validators.validatePhone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Password',
                                controller: _passwordController,
                                obscureText: true,
                                validator: Validators.validatePassword,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AppColors.card,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  labelText: 'Role',
                                  labelStyle: const TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                dropdownColor: AppColors.surface,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'customer',
                                    child: Text('Customer'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'artisan',
                                    child: Text('Artisan'),
                                  ),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedRole = value!),
                              ),
                              const SizedBox(height: 24),
                              if (authState.isLoading)
                                const LoadingIndicator()
                              else
                                AppButton(
                                  text: 'Register',
                                  onPressed: _register,
                                  gradient: true,
                                ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.go(Routes.login),
                                child: const Text(
                                  Strings.alreadyHaveAccount,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
