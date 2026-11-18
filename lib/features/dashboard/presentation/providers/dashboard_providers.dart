import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/dashboard_local_data_source.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_account_usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import 'dashboard_notifier.dart';
import 'dashboard_state.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return const MockApiClient();
});

final dashboardRemoteDataSourceProvider =
    Provider<DashboardRemoteDataSource>((ref) {
  return DashboardRemoteDataSourceImpl(apiClient: ref.watch(apiClientProvider));
});

final dashboardLocalDataSourceProvider =
    Provider<DashboardLocalDataSource>((ref) {
  return DashboardLocalDataSourceImpl();
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
    localDataSource: ref.watch(dashboardLocalDataSourceProvider),
  );
});

final getAccountUseCaseProvider = Provider<GetAccountUseCase>((ref) {
  return GetAccountUseCase(ref.watch(dashboardRepositoryProvider));
});

final getRecentTransactionsUseCaseProvider =
    Provider<GetRecentTransactionsUseCase>((ref) {
  return GetRecentTransactionsUseCase(ref.watch(dashboardRepositoryProvider));
});

final dashboardNotifierProvider =
    NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);
