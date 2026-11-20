import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/operations_remote_data_source.dart';
import '../../data/repositories/operations_repository_impl.dart';
import '../../domain/repositories/operations_repository.dart';
import '../../domain/usecases/currency_exchange_usecase.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../../domain/usecases/internal_transfer_usecase.dart';
import '../../domain/usecases/withdraw_usecase.dart';
import 'operations_notifier.dart';
import 'operations_state.dart';

final operationsRemoteDataSourceProvider =
    Provider<OperationsRemoteDataSource>((ref) {
  return OperationsRemoteDataSourceImpl(dioClient: DioClient());
});

final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return OperationsRepositoryImpl(
    remoteDataSource: ref.watch(operationsRemoteDataSourceProvider),
  );
});

final depositUseCaseProvider = Provider<DepositUseCase>((ref) {
  return DepositUseCase(ref.watch(operationsRepositoryProvider));
});

final withdrawUseCaseProvider = Provider<WithdrawUseCase>((ref) {
  return WithdrawUseCase(ref.watch(operationsRepositoryProvider));
});

final internalTransferUseCaseProvider =
    Provider<InternalTransferUseCase>((ref) {
  return InternalTransferUseCase(ref.watch(operationsRepositoryProvider));
});

final currencyExchangeUseCaseProvider =
    Provider<CurrencyExchangeUseCase>((ref) {
  return CurrencyExchangeUseCase(ref.watch(operationsRepositoryProvider));
});

final operationsNotifierProvider =
    NotifierProvider<OperationsNotifier, OperationsState>(
  OperationsNotifier.new,
);
