import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late Future<List<Chat>> _chatsFuture;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      _chatsFuture = ref.read(getChatsProvider).call(user.id);
      _chatsFuture.then((chats) {
        setState(() {
          // For now, count chats as "unread" (we can add read status later)
          _unreadCount = chats.length;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    if (user?.role == 'customer') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(Routes.home);
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null || user.role != 'artisan') {
      return Scaffold(
        body: Center(
          child: Text(
            'Not authorized',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    if (user == null || user.role != 'artisan') {
      return Scaffold(
        body: Center(
          child: Text(
            'Not authorized',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    }

    final statsAsync = ref.watch(dashboardStatsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(dashboardStatsProvider(user.id));
          _loadChats();
        },
        child: SafeArea(
          child: Column(
            children: [
              // -- Custom Greeting Header with Blue Gradient --
              _buildGreetingHeader(context, user),
              const SizedBox(height: 8),

              // -- Stats Cards --
              Expanded(
                child: statsAsync.when(
                  data: (stats) => SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Stats Row with new design
                        _buildStatsRow(context, stats),
                        const SizedBox(height: 20),

                        // Quick Actions Card
                        _buildQuickActions(context),
                        const SizedBox(height: 16),

                        // Recent Chats
                        _buildRecentChats(context),
                        const SizedBox(height: 16),

                        // Logout Button
                        _buildLogoutCard(context),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => ErrorState(
                    message: err.toString(),
                    onRetry: () => ref.refresh(dashboardStatsProvider(user.id)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Greeting Header with Blue Gradient ----------
  Widget _buildGreetingHeader(BuildContext context, UserEntity user) {
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
              imageUrl: user.profileImage,
              name: user.name,
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
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Text(
                  'Artisan Dashboard',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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

  // ---------- Stats Row ----------
  Widget _buildStatsRow(BuildContext context, DashboardStats stats) {
    return Row(
      children: [
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.chat,
          label: 'Chats',
          value: stats.chatCount.toString(),
          color: AppColors.secondary,
          gradient: true,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.star,
          label: 'Rating',
          value: stats.averageRating.toStringAsFixed(1),
          color: const Color(0xFFFFAB00),
          gradient: true,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool gradient = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: gradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                )
              : null,
          color: gradient ? null : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Quick Actions ----------
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit Profile',
                onTap: () => context.push(Routes.editProfile),
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.chat_bubble,
                label: 'Messages',
                onTap: () => context.go(Routes.chatList),
                badge: _unreadCount,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              Stack(children: [Icon(icon, color: AppColors.primary, size: 28)]),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- Recent Chats ----------
  Widget _buildRecentChats(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Messages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () => context.go(Routes.chatList),
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Chat>>(
            future: _chatsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final chats = snapshot.data ?? [];
              if (chats.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              // Show only first 3 chats
              final displayChats = chats.take(3).toList();
              return Column(
                children: displayChats.map((chat) {
                  final isCustomer =
                      chat.customerId == ref.read(authStateProvider).value?.id;
                  final otherId = isCustomer ? chat.artisanId : chat.customerId;

                  return FutureBuilder(
                    future: ref
                        .read(firestoreProvider)
                        .collection('users')
                        .doc(otherId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) return const SizedBox.shrink();
                      final data = userSnapshot.data!.data()!;
                      final name = data['name'] ?? 'Unknown';
                      final profileImage = data['profileImage'];

                      return ListTile(
                        leading: ProfileAvatar(
                          imageUrl: profileImage,
                          name: name,
                          radius: 22,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          chat.lastMessage.isEmpty
                              ? 'No messages'
                              : chat.lastMessage,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          Formatters.formatTime(chat.updatedAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
                        onTap: () {
                          context.push(
                            '${Routes.chat.replaceFirst(':chatId', chat.id)}?otherUserId=$otherId',
                          );
                        },
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------- Logout Card ----------
  Widget _buildLogoutCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Logout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
              context.go(Routes.login);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
