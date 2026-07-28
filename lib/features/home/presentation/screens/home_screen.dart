import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Add this method to the _HomeScreenState class
  Future<void> _refresh() async {
    // Show loading state by refreshing the provider
    ref.refresh(homeViewModelProvider);
    // Show feedback
    if (mounted) {
      context.showSnackBar('Refreshed!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeViewModelProvider);
    final user = ref.watch(authStateProvider).value;
    if (user?.role == 'artisan') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(Routes.dashboard);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SafeArea(
          child: Column(
            children: [
              // -- Custom Greeting Header --
              _buildGreetingHeader(context, user),
              const SizedBox(height: 8),

              // -- Search Bar --
              _buildSearchBar(context),
              const SizedBox(height: 16),

              // -- Main Content (scrollable) --
              Expanded(
                child: homeAsync.when(
                  data: (viewModel) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Categories
                        _buildCategorySection(context, viewModel.categories),
                        const SizedBox(height: 24),

                        // Featured Artisans
                        _buildFeaturedSection(
                          context,
                          viewModel.featuredArtisans,
                        ),
                        const SizedBox(height: 24),

                        // Recently Joined
                        _buildRecentSection(context, viewModel.recentlyJoined),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => ErrorState(
                    message: err.toString(),
                    onRetry: () => ref.refresh(homeViewModelProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Greeting Header ----------
  Widget _buildGreetingHeader(BuildContext context, user) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: ProfileAvatar(
              imageUrl: user?.profileImage,
              name: user?.name ?? 'User',
              radius: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: Text(
                    user?.name ?? 'Friend',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ✅ Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Show refresh indicator
              _refresh();
            },
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'profile') {
                context.push('/profile');
              } else if (value == 'logout') {
                ref.read(authNotifierProvider.notifier).logout();
                context.go(Routes.login);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Search Bar ----------
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showSearchDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.card.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Text(
                Strings.searchHint,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              const Icon(Icons.tune, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Categories ----------
  Widget _buildCategorySection(BuildContext context, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.categories,
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return
              // In _buildCategorySection, update the GestureDetector:
              GestureDetector(
                onTap: () {
                  // Navigate to search results with this category
                  context.push('${Routes.searchResults}?q=$cat');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------- Featured Section ----------
  Widget _buildFeaturedSection(
    BuildContext context,
    List<ArtisanSummary> artisans,
  ) {
    if (artisans.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.featured,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            TextButton(
              onPressed: () {
                context.push('/all-artisans/featured/Featured Artisans');
              },
              child: const Text(
                'See All',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: artisans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final artisan = artisans[index];
              return _buildArtisanCard(context, artisan);
            },
          ),
        ),
      ],
    );
  }

  // ---------- Recently Joined Section ----------
  // ---------- Recently Joined Section ----------
  Widget _buildRecentSection(
    BuildContext context,
    List<ArtisanSummary> artisans,
  ) {
    if (artisans.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Strings.recentlyJoined,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            TextButton(
              onPressed: () {
                context.push('/all-artisans/recent/Recently Joined');
              },
              child: const Text(
                'See All',
                style: TextStyle(color: AppColors.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ✅ Fix: Use Expanded with LayoutBuilder for dynamic height
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              constraints: BoxConstraints(
                maxHeight:
                    constraints.maxHeight * 0.4, // 40% of available space
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: artisans.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final artisan = artisans[index];
                  return _buildArtisanListTile(context, artisan);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------- Artisan Card (Horizontal) ----------
  Widget _buildArtisanCard(BuildContext context, ArtisanSummary artisan) {
    return GestureDetector(
      onTap: () => context.push(
        '${Routes.artisanProfile.replaceFirst(':id', artisan.id)}',
      ),
      child: SizedBox(
        width: 160,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileAvatar(
                  imageUrl: artisan.profileImage,
                  name: artisan.name,
                  radius: 35,
                ),
                const SizedBox(height: 8),
                Text(
                  artisan.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artisan.profession,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                RatingStars(rating: artisan.rating, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- Artisan List Tile (Vertical) ----------
  Widget _buildArtisanListTile(BuildContext context, ArtisanSummary artisan) {
    return ListTile(
      leading: ProfileAvatar(
        imageUrl: artisan.profileImage,
        name: artisan.name,
      ),
      title: Text(
        artisan.name,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        artisan.profession,
        style: const TextStyle(color: AppColors.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingStars(rating: artisan.rating, size: 14),
          const SizedBox(width: 4),
          Text(
            artisan.rating.toStringAsFixed(1),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
      onTap: () => context.push(
        '${Routes.artisanProfile.replaceFirst(':id', artisan.id)}',
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Search Artisans',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick category chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
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
                  ].map((category) {
                    return ActionChip(
                      label: Text(
                        category,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.push('${Routes.searchResults}?q=$category');
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.textHint),
            const SizedBox(height: 8),
            TextField(
              onSubmitted: (value) {
                Navigator.pop(ctx);
                context.push('${Routes.searchResults}?q=$value');
              },
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: Strings.searchHint,
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.card,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
