import 'dart:ui'; // Required for BackdropFilter
import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.search_rounded,
      title: 'Find Artisans',
      description: 'Search for skilled professionals in your area.',
      color: const Color(0xFF2563EB), // Modern Primary Blue
    ),
    OnboardingPage(
      icon: Icons.verified_user_rounded,
      title: 'Verified Profiles',
      description: 'View portfolios, ratings, and reviews before hiring.',
      color: const Color(0xFFA855F7), // Accent Purple
    ),
    OnboardingPage(
      icon: Icons.chat_bubble_rounded,
      title: 'Chat Instantly',
      description: 'Connect with artisans directly through the app.',
      color: const Color(0xFF10B981), // Accent Emerald
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1581094794329-c8112a89af12?q=80&w=1000',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Global Blur Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
              child: Container(color: Colors.black.withOpacity(0.35)),
            ),
          ),

          // 3. PageView Content Layer
          SafeArea(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: _pages.map((page) => _buildPage(page)).toList(),
            ),
          ),

          // 4. Floating Glassmorphic Bottom Navigation Container
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                              (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: _currentPage == index
                                  ? const Color(0xFF2563EB)
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Next / Get Started Action Button
                      AppButton(
                        text: _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            context.go(Routes.login);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),

                      // Skip Button
                      if (_currentPage < _pages.length - 1) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go(Routes.login),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glass Avatar / Icon Box
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withOpacity(0.2),
              border: Border.all(
                color: page.color.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          // Extra bottom padding to compensate for the bottom panel height
          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}