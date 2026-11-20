import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/user_facing_error.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../operations/data/datasources/operations_remote_data_source.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String email, String password, {String? tenantSlug}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final rawUser = await loginUseCase(
        LoginParams(email: email, password: password, tenantSlug: tenantSlug),
      );
      final user = UserEntity(
        id: rawUser.id,
        email: rawUser.email,
        name: rawUser.name,
        documentNumber: rawUser.documentNumber,
        phone: rawUser.phone,
        token: rawUser.token,
        role: rawUser.role,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      final msg = e is ServerException ? e.message : UserFacingError.from(e);
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
      return false;
    }
  }

  void logout() {
    DioClient.setAuthToken(null);
    OperationsRemoteDataSourceImpl.onUserLogout();
    state = const AuthState();
  }

  Future<bool> loginWithBiometrics() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginWithBiometrics();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      final msg = e is ServerException ? e.message : UserFacingError.from(e);
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String documentNumber,
    required String email,
    required String phone,
    required String password,
    String transactionalPin = '1234',
    String? tenantSlug,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.register(
        fullName: fullName,
        documentNumber: documentNumber,
        email: email,
        phone: phone,
        password: password,
        transactionalPin: transactionalPin,
        tenantSlug: tenantSlug,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      final msg = e is ServerException ? e.message : UserFacingError.from(e);
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
      return false;
    }
  }
}
