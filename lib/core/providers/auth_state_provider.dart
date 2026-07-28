import 'package:artisan/export.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<UserEntity?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  await for (final user in auth.authStateChanges()) {
    if (user == null) {
      yield null;
    } else {
      final userData = await ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        yield UserEntity.fromMap(userData.data()!, user.uid);
      } else {
        yield null;
      }
    }
  }
});
