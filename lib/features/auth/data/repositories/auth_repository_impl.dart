import 'package:artisan/export.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepositoryImpl(this.auth, this.firestore);

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final userCred = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = userCred.user!;
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) throw Exception('User data not found');
      return UserModel.fromMap(doc.data()!, user.uid).toEntity();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  @override
  Future<UserEntity> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) async {
    try {
      print('📝 Registering user: $name, $email, $phone, $role');

      // 1. Create auth user
      final userCred = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = userCred.user!;
      print('✅ Auth user created: ${user.uid}');

      // 2. Save user document with ALL fields
      final userData = {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'profileImage': null,
        'location': null,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await firestore.collection('users').doc(user.uid).set(userData);
      print('✅ User document saved');

      // 3. If artisan, create artisan doc with profession from registration
      if (role == 'artisan') {
        // Get the profession from the registration form
        // We need to pass this from the register screen
        await firestore.collection('artisans').doc(user.uid).set({
          'userId': user.uid,
          'profession': '', // Will be set during profile completion
          'bio': '',
          'experienceYears': 0,
          'serviceArea': '',
          'rating': 0.0,
          'phone': phone, // Store phone in artisan doc too
          'name': name, // Store name in artisan doc too for quick access
          'createdAt': FieldValue.serverTimestamp(),
        });
        print('✅ Artisan document created');
      }

      // 4. Return entity
      return UserEntity(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        profileImage: null,
        location: null,
        createdAt: DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'weak-password':
          message = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email.';
          break;
        default:
          message = e.message ?? 'Registration failed';
      }
      throw Exception(message);
    } catch (e) {
      print('❌ Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email.trim());
  }
}
