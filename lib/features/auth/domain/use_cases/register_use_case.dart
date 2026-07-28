import 'package:artisan/export.dart';

class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserEntity> call(
    String name,
    String email,
    String phone,
    String password,
    String role,
  ) {
    return repository.register(name, email, phone, password, role);
  }
}
