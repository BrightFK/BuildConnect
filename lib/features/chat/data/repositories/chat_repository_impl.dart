import 'package:artisan/export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore firestore;

  ChatRepositoryImpl(this.firestore);

  @override
  Future<List<Chat>> getChats(String userId) async {
    try {
      print('🔍 Fetching chats for user: $userId');

      // Try with composite query first
      try {
        final snapshot = await firestore
            .collection('chats')
            .where('customerId', isEqualTo: userId)
            .orderBy('updatedAt', descending: true)
            .get();

        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Chat(
            id: doc.id,
            customerId: data['customerId'] ?? '',
            artisanId: data['artisanId'] ?? '',
            lastMessage: data['lastMessage'] ?? '',
            updatedAt:
                (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();
      } catch (e) {
        // If index not ready, try without ordering
        print('⚠️ Ordering failed, trying without order');
        final snapshot = await firestore
            .collection('chats')
            .where('customerId', isEqualTo: userId)
            .get();

        final chats1 = snapshot.docs.map((doc) {
          final data = doc.data();
          return Chat(
            id: doc.id,
            customerId: data['customerId'] ?? '',
            artisanId: data['artisanId'] ?? '',
            lastMessage: data['lastMessage'] ?? '',
            updatedAt:
                (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();

        // Also get chats where user is artisan
        final snapshot2 = await firestore
            .collection('chats')
            .where('artisanId', isEqualTo: userId)
            .get();

        final chats2 = snapshot2.docs.map((doc) {
          final data = doc.data();
          return Chat(
            id: doc.id,
            customerId: data['customerId'] ?? '',
            artisanId: data['artisanId'] ?? '',
            lastMessage: data['lastMessage'] ?? '',
            updatedAt:
                (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        }).toList();

        // Combine and sort manually
        final allChats = [...chats1, ...chats2];
        allChats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return allChats;
      }
    } catch (e) {
      print('❌ Error fetching chats: $e');
      return [];
    }
  }

  @override
  Stream<List<Message>> getMessages(String chatId) async* {
    try {
      print('🔍 Getting messages for chat: $chatId');

      // Check if chat exists
      final chatDoc = await firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        print('⚠️ Chat document does not exist: $chatId');
        yield [];
        return;
      }

      // Try with ordering first
      try {
        yield* firestore
            .collection('messages')
            .where('chatId', isEqualTo: chatId)
            .orderBy('timestamp', descending: false)
            .snapshots()
            .map((snapshot) {
              print('📄 Received ${snapshot.docs.length} messages');
              return snapshot.docs.map((doc) {
                final data = doc.data();
                return Message(
                  id: doc.id,
                  chatId: data['chatId'] ?? '',
                  senderId: data['senderId'] ?? '',
                  message: data['message'] ?? '',
                  timestamp:
                      (data['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                );
              }).toList();
            });
      } catch (e) {
        // If index not ready, try without ordering
        print('⚠️ Ordering failed, trying without order');
        yield* firestore
            .collection('messages')
            .where('chatId', isEqualTo: chatId)
            .snapshots()
            .map((snapshot) {
              print('📄 Received ${snapshot.docs.length} messages (no order)');
              return snapshot.docs.map((doc) {
                final data = doc.data();
                return Message(
                  id: doc.id,
                  chatId: data['chatId'] ?? '',
                  senderId: data['senderId'] ?? '',
                  message: data['message'] ?? '',
                  timestamp:
                      (data['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                );
              }).toList();
            });
      }
    } catch (e) {
      print('❌ Error getting messages stream: $e');
      yield [];
    }
  }

  @override
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String message,
  ) async {
    try {
      print('📤 Sending message to chat: $chatId');

      final chatDoc = await firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        throw Exception('Chat not found');
      }

      final messageRef = firestore.collection('messages').doc();
      await messageRef.set({
        'chatId': chatId,
        'senderId': senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Message sent successfully');
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }
}
