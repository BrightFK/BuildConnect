import 'package:artisan/export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(firestoreProvider));
});

// Use Case Providers
final getChatsProvider = Provider<GetChats>((ref) {
  return GetChats(ref.watch(chatRepositoryProvider));
});

final getMessagesProvider = Provider<GetMessages>((ref) {
  return GetMessages(ref.watch(chatRepositoryProvider));
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
});

// Chat List Provider with automatic refresh
final chatListProvider = FutureProvider<List<Chat>>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return [];
  try {
    final chats = await ref.watch(getChatsProvider).call(user.id);
    print('📋 Loaded ${chats.length} chats for user: ${user.id}');
    return chats;
  } catch (e) {
    print('❌ Chat list error: $e');
    return [];
  }
});

// Unread count provider
final unreadCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0;
  try {
    final chats = await ref.watch(getChatsProvider).call(user.id);
    // Count chats with messages (or where last message is not from current user)
    // For now, count all chats with messages
    return chats.where((chat) => chat.lastMessage.isNotEmpty).length;
  } catch (e) {
    return 0;
  }
});
