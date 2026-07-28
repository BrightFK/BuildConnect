import 'package:artisan/export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        // ✅ Add back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            // Check if there's a previous page, otherwise go to dashboard/home
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // If no previous page, go back to dashboard or home based on user role
              final user = ref.read(authStateProvider).value;
              if (user?.role == 'artisan') {
                context.go(Routes.dashboard);
              } else {
                context.go(Routes.home);
              }
            }
          },
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () => ref.refresh(chatListProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Please login'))
          : _buildChatList(ref, user.id),
    );
  }

  Widget _buildChatList(WidgetRef ref, String userId) {
    final chatsAsync = ref.watch(chatListProvider);

    return chatsAsync.when(
      data: (chats) {
        if (chats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start a conversation with an artisan',
                  style: TextStyle(fontSize: 14, color: AppColors.textHint),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final isCustomer = chat.customerId == userId;
            final otherId = isCustomer ? chat.artisanId : chat.customerId;

            return _buildChatTile(context, ref, chat, otherId);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.refresh(chatListProvider),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context,
    WidgetRef ref,
    Chat chat,
    String otherId,
  ) {
    return FutureBuilder(
      future: ref
          .read(firestoreProvider)
          .collection('users')
          .doc(otherId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: ListTile(
              leading: CircularProgressIndicator(),
              title: Text('Loading...'),
            ),
          );
        }

        final data = snapshot.data!.data()!;
        final name = data['name'] ?? 'Unknown';
        final profileImage = data['profileImage'];

        // Check if there are unread messages
        final hasUnread = chat.lastMessage.isNotEmpty;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ProfileAvatar(
              imageUrl: profileImage,
              name: name,
              radius: 30,
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              chat.lastMessage.isEmpty ? 'No messages yet' : chat.lastMessage,
              style: TextStyle(
                color: hasUnread
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Formatters.formatTime(chat.updatedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
            onTap: () {
              context.push(
                '${Routes.chat.replaceFirst(':chatId', chat.id)}?otherUserId=$otherId',
              );
            },
          ),
        );
      },
    );
  }
}
