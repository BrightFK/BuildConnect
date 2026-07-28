// ============================================================
//  BUILDERCONNECT – COMPLETE BARREL EXPORT
//  Organized by feature – no directory changes
// ============================================================

// ------------------------- CORE ----------------------------
export 'core/constants/app_constants.dart';
export 'core/constants/asset_paths.dart';
export 'core/constants/strings.dart';
export 'core/providers/auth_state_provider.dart';
export 'core/providers/firebase_providers.dart';
export 'core/routing/app_router.dart';
export 'core/routing/routes.dart';
export 'core/theme/app_theme.dart';
export 'core/theme/colors.dart';
export 'core/theme/typography.dart';
export 'core/utils/extensions.dart';
export 'core/utils/formatters.dart';
export 'core/utils/seed_data.dart';
export 'core/utils/validators.dart';
// ---------------- FEATURE: ARTISAN_DASHBOARD -------------
// Data
export 'features/artisan_dashboard/data/models/artisan_dashboard_dto.dart';
export 'features/artisan_dashboard/data/repositories/dashboard_repository.dart';
export 'features/artisan_dashboard/data/repositories/dashboard_repository_impl.dart';
// Domain
export 'features/artisan_dashboard/domain/entities/dashboard_stats.dart';
export 'features/artisan_dashboard/domain/use_cases/get_dashboard_data.dart';
export 'features/artisan_dashboard/domain/use_cases/update_profile.dart';
export 'features/artisan_dashboard/domain/use_cases/upload_portfolio.dart';
// Presentation – Providers
export 'features/artisan_dashboard/presentation/providers/dashboard_notifier.dart';
// Presentation – Screens
export 'features/artisan_dashboard/presentation/screens/dashboard_screen.dart';
export 'features/artisan_dashboard/presentation/screens/edit_profile_screen.dart';
// Presentation – Widgets
export 'features/artisan_dashboard/presentation/widgets/stats_card.dart';
// ---------------- FEATURE: ARTISAN_PROFILE ----------------
// Data
export 'features/artisan_profile/data/models/artisan_profile_dto.dart';
export 'features/artisan_profile/data/models/portfolio_dto.dart';
export 'features/artisan_profile/data/repositories/artisan_profile_repository_impl.dart';
// Domain
export 'features/artisan_profile/domain/entities/artisan_profile.dart';
export 'features/artisan_profile/domain/entities/portfolio_item.dart';
export 'features/artisan_profile/domain/use_cases/get_artisan_profile.dart';
export 'features/artisan_profile/domain/use_cases/get_portfolio.dart';
// Presentation – Providers
export 'features/artisan_profile/presentation/providers/artisan_profile_notifier.dart';
// Presentation – Screens
export 'features/artisan_profile/presentation/screens/artisan_profile_screen.dart';
// Presentation – Widgets
export 'features/artisan_profile/presentation/widgets/portfolio_grid.dart';
export 'features/artisan_profile/presentation/widgets/profile_header.dart';
export 'features/artisan_profile/presentation/widgets/review_card.dart';
// -------------------- FEATURE: AUTH -----------------------
// Data
export 'features/auth/data/models/user_model.dart';
export 'features/auth/data/repositories/auth_repository_impl.dart';
// Domain
export 'features/auth/domain/entities/user.dart';
export 'features/auth/domain/repositories/artisan_profile_repository.dart';
export 'features/auth/domain/repositories/auth_repository.dart';
export 'features/auth/domain/use_cases/login_use_case.dart';
export 'features/auth/domain/use_cases/register_use_case.dart';
// Presentation – Providers
export 'features/auth/presentation/providers/auth_notifier.dart';
// Presentation – Screens
export 'features/auth/presentation/screens/choose_role_screen.dart';
export 'features/auth/presentation/screens/complete_profile_screen.dart';
export 'features/auth/presentation/screens/login_screen.dart';
export 'features/auth/presentation/screens/onboarding_screen.dart';
export 'features/auth/presentation/screens/register_screen.dart';
export 'features/auth/presentation/screens/splash_screen.dart';
// Presentation – Widgets
export 'features/auth/presentation/widgets/auth_form_field.dart';
export 'features/auth/presentation/widgets/role_toggle.dart';
// -------------------- FEATURE: CHAT -----------------------
// Data
export 'features/chat/data/models/chat_dto.dart';
export 'features/chat/data/models/message_dto.dart';
export 'features/chat/data/repositories/chat_repository_impl.dart';
// Domain
export 'features/chat/domain/entities/chat.dart';
export 'features/chat/domain/entities/message.dart';
export 'features/chat/domain/repositories/chat_repository.dart';
export 'features/chat/domain/use_cases/get_chats.dart';
export 'features/chat/domain/use_cases/get_messages.dart';
export 'features/chat/domain/use_cases/send_message.dart';
// Presentation – Providers
export 'features/chat/presentation/providers/chat_notifier.dart';
// Presentation – Screens
export 'features/chat/presentation/screens/chat_list_screen.dart';
export 'features/chat/presentation/screens/chat_screen.dart';
// Presentation – Widgets
export 'features/chat/presentation/widgets/message_bubble.dart';
export 'features/chat/presentation/widgets/message_input.dart';
// -------------------- FEATURE: HOME -----------------------
// Data
export 'features/home/data/models/artisan_card_dto.dart';
export 'features/home/data/repositories/home_repository_impl.dart';
// Domain
export 'features/home/domain/entities/artisan_summary.dart';
export 'features/home/domain/repositories/home_repository.dart';
export 'features/home/domain/use_cases/get_categories.dart';
export 'features/home/domain/use_cases/get_featured_artisans.dart';
// Presentation – Providers
export 'features/home/presentation/providers/home_view_model.dart';
export 'features/home/presentation/screens/all_artisans_screen.dart';
// Presentation – Screens
export 'features/home/presentation/screens/home_screen.dart';
// Presentation – Widgets
export 'features/home/presentation/widgets/artisan_card.dart';
export 'features/home/presentation/widgets/category_grid.dart';
export 'features/home/presentation/widgets/search_bar.dart';
export 'features/profile/presentation/screens/profile_screen.dart';
export 'features/profile/presentation/screens/terms_privacy_screen.dart';
// -------------------- FEATURE: SEARCH ---------------------
// Presentation – Providers
export 'features/search/presentation/providers/search_notifier.dart';
// Presentation – Screens
export 'features/search/presentation/screens/search_results_screen.dart';
// ------------------------- SHARED --------------------------
export 'shared/layouts/auth_scaffold.dart';
export 'shared/layouts/main_scaffold.dart';
export 'shared/widgets/app_button.dart';
export 'shared/widgets/app_card.dart';
export 'shared/widgets/app_input.dart';
export 'shared/widgets/empty_state.dart';
export 'shared/widgets/error_state.dart';
export 'shared/widgets/loading_indicator.dart';
export 'shared/widgets/profile_avatar.dart';
export 'shared/widgets/rating_stars.dart';
export 'shared/widgets/refresh_button.dart';
