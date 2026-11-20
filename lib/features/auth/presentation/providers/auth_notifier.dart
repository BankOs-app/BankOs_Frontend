import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login(String email, String password,
      {UserRole role = UserRole.client}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      final rawUser = await loginUseCase(
        LoginParams(email: email, password: password),
      );
      final assignedRole =
          (email.toLowerCase().contains('admin') || role == UserRole.admin)
              ? UserRole.admin
              : UserRole.client;
      final user = UserEntity(
        id: rawUser.id,
        email: rawUser.email,
        name: rawUser.name,
        documentNumber: rawUser.documentNumber,
        phone: rawUser.phone,
        token: rawUser.token,
        role: assignedRole,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      final msg = e is ServerException
          ? e.message
          : e.toString().replaceFirst('ServerException: ', '').replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    }
  }

  Future<bool> loginWithBiometrics() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginWithBiometrics();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      final msg = e is ServerException
          ? e.message
          : e.toString().replaceFirst('ServerException: ', '').replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
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
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
      return true;
    } catch (e) {
      final msg = e is ServerException
          ? e.message
          : e.toString().replaceFirst('ServerException: ', '').replaceFirst('Exception: ', '');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    }
  }
}
