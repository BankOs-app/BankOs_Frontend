import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> loginWithBiometrics();
  Future<void> sendPasswordReset(String email);
  Future<UserModel> register({
    required String fullName,
    required String documentNumber,
    required String email,
    required String phone,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> login(String email, String password) async {
    // Simulated network delay matching BankOS auth API
    await Future.delayed(const Duration(milliseconds: 350));
    return UserModel(
      id: 'usr_001',
      email: email,
      name: 'BankOS User',
      token: 'jwt_mock_token_bankos_2026',
    );
  }

  @override
  Future<UserModel> loginWithBiometrics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserModel(
      id: 'usr_001',
      email: 'user@bankos.com',
      name: 'BankOS User',
      token: 'jwt_mock_token_biometric_2026',
    );
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String documentNumber,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: fullName,
      documentNumber: documentNumber,
      phone: phone,
      token: 'jwt_mock_token_registered_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}
