import 'dart:ui';

import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(authNotifierProvider.notifier);
      await notifier.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Use addPostFrameCallback to ensure widget is still mounted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final authState = ref.read(authNotifierProvider);
        authState.when(
          data: (user) {
            if (user != null) {
              // ✅ Check role and navigate accordingly
              if (user.role == 'artisan') {
                context.go(Routes.dashboard);
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
                  // App icon & title
                  const Icon(Icons.build, size: 80, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text(
                    'BuilderConnect',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue',
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
                                label: 'Email',
                                controller: _emailController,
                                validator: Validators.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Password',
                                controller: _passwordController,
                                obscureText: true,
                                validator: Validators.validatePassword,
                              ),
                              const SizedBox(height: 24),
                              if (authState.isLoading)
                                const LoadingIndicator()
                              else
                                AppButton(
                                  text: 'Login',
                                  onPressed: _login,
                                  gradient: true,
                                ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () => context.go(Routes.register),
                                child: const Text(
                                  Strings.dontHaveAccount,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Forgot password
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(color: AppColors.textHint),
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
