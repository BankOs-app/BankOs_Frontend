import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> loginWithBiometrics() {
    return remoteDataSource.loginWithBiometrics();
  }

  @override
  Future<void> sendPasswordReset(String email) {
    return remoteDataSource.sendPasswordReset(email);
  }

  @override
  Future<UserEntity> register({
    required String fullName,
    required String documentNumber,
    required String email,
    required String phone,
    required String password,
    String transactionalPin = '1234',
  }) {
    return remoteDataSource.register(
      fullName: fullName,
      documentNumber: documentNumber,
      email: email,
      phone: phone,
      password: password,
      transactionalPin: transactionalPin,
    );
  }
}
