import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.value;
  final isLoggedIn = user != null;

  return GoRouter(
    initialLocation: Routes.splash,
    redirect: (context, state) {
      // Check for deep link artisan ID
      if (deepLinkArtisanId != null && isLoggedIn) {
        final id = deepLinkArtisanId!;
        deepLinkArtisanId = null;
        return '/artisan-profile/$id';
      }

      final isOnAuthPage =
          state.matchedLocation == Routes.splash ||
          state.matchedLocation == Routes.onboarding ||
          state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.register ||
          state.matchedLocation == Routes.chooseRole;

      // If there's a pending artisan ID and user is logged in
      if (deepLinkArtisanId != null && isLoggedIn) {
        final id = deepLinkArtisanId!;
        deepLinkArtisanId = null;
        return '/artisan-profile/$id';
      }

      // If not logged in and trying to access protected page
      if (!isLoggedIn && !isOnAuthPage) {
        // Store the intended destination to redirect after login
        _pendingRedirect = state.matchedLocation;
        return Routes.login;
      }

      // If logged in and trying to access auth pages
      if (isLoggedIn && isOnAuthPage) {
        // If there's a pending redirect (deep link)
        if (_pendingRedirect != null &&
            _pendingRedirect!.contains('/artisan-profile')) {
          final redirect = _pendingRedirect!;
          _pendingRedirect = null;
          return redirect;
        }

        // ✅ Role-based navigation
        if (user.role == 'artisan') {
          // Check if artisan has completed profile
          // We'll check this in the dashboard screen instead
          return Routes.dashboard;
        }
        return Routes.home;
      }

      // ✅ If logged in and trying to access wrong role page
      if (isLoggedIn) {
        if (user.role == 'artisan' && state.matchedLocation == Routes.home) {
          return Routes.dashboard;
        }
        if (user.role == 'customer' &&
            state.matchedLocation == Routes.dashboard) {
          return Routes.home;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.chooseRole,
        builder: (context, state) => const ChooseRoleScreen(),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.searchResults,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchResultsScreen(query: query);
        },
      ),
      GoRoute(
        path: Routes.artisanProfile,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ArtisanProfileScreen(artisanId: id);
        },
      ),
      GoRoute(
        path: Routes.chatList,
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: Routes.chat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';
          return ChatScreen(chatId: chatId, otherUserId: otherUserId);
        },
      ),
      GoRoute(
        path: Routes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: Routes.allArtisans,
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'featured';
          final title = state.pathParameters['title'] ?? 'Artisans';
          return AllArtisansScreen(title: title, type: type);
        },
      ),
      GoRoute(
        path: Routes.termsPrivacy,
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'] ?? 'terms';
          return TermsPrivacyScreen(initialTab: tab);
        },
      ),
      GoRoute(
        path: Routes.chat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId'] ?? '';
          final otherUserId = state.uri.queryParameters['otherUserId'] ?? '';

          if (chatId.isEmpty || otherUserId.isEmpty) {
            // Show error screen if parameters are missing
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Invalid chat session',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again from the artisan profile',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Go Back',
                      onPressed: () => Navigator.pop(context),
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
            );
          }

          return ChatScreen(chatId: chatId, otherUserId: otherUserId);
        },
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

// Global variables for deep link handling
String? _pendingRedirect;
String? _pendingArtisanId;
