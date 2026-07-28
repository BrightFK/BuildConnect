class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const chooseRole = '/choose-role';
  static const home = '/home';
  static const searchResults = '/search-results';
  static const artisanProfile = '/artisan-profile/:id';
  static const chatList = '/chat-list';
  static const chat = '/chat/:chatId';
  static const dashboard = '/dashboard';
  static const editProfile = '/edit-profile';
  static const completeProfile = '/complete-profile';
  static const allArtisans = '/all-artisans/:type/:title';

  // Deep link base URL (replace with your actual domain)
  static const deepLinkBase = 'https://builderconnect.com';

  // Helper to generate shareable link
  static String getArtisanShareLink(String artisanId) {
    return '$deepLinkBase/artisan-profile/$artisanId';
  }

  static const profile = '/profile';
  static const termsPrivacy = '/terms-privacy';
}
