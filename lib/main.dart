import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uni_links/uni_links.dart';

import 'export.dart';
import 'firebase_options.dart';

// Global variable for deep link
String? deepLinkArtisanId;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Check for deep link on web
  if (kIsWeb) {
    final uri = Uri.base;
    if (uri.path.contains('/artisan-profile/')) {
      final artisanId = uri.path.split('/').last;
      deepLinkArtisanId = artisanId;
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _BuilderConnectAppState();
}

class _BuilderConnectAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      // Get initial link
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Listen for future links
      linkStream.listen(
        (link) {
          _handleDeepLink(link!);
        },
        onError: (err) {
          print('❌ Deep link error: $err');
        },
      );
    } catch (e) {
      print('❌ Error initializing deep links: $e');
    }
  }

  void _handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      if (uri.path.contains('/artisan-profile/')) {
        final artisanId = uri.path.split('/').last;
        deepLinkArtisanId = artisanId;
        if (mounted) {
          context.go('/artisan-profile/$artisanId');
        }
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (deepLinkArtisanId != null && mounted) {
        context.go('/artisan-profile/$deepLinkArtisanId');
      }
    });

    return MaterialApp.router(
      title: 'BuilderConnect',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
