import 'package:artisan/export.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(
    String name,
    String email,
    String phone,
    String password,
    String role,
  );
  Future<void> logout();
  Future<void> resetPassword(String email);
}
