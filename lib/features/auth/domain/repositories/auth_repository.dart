import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> loginWithBiometrics();
  Future<void> sendPasswordReset(String email);
  Future<UserEntity> register({
    required String fullName,
    required String documentNumber,
    required String email,
    required String phone,
    required String password,
    String transactionalPin,
  });
}
