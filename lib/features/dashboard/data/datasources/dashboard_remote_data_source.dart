import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/account_model.dart';
import '../models/transaction_model.dart';

abstract class DashboardRemoteDataSource {
  Future<AccountModel> getAccountSummary();
  Future<List<TransactionModel>> getRecentTransactions();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AccountModel> getAccountSummary() async {
    final response = await apiClient.get(ApiEndpoints.accountSummary);
    return AccountModel.fromJson(response);
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions() async {
    final response = await apiClient.get(ApiEndpoints.recentTransactions);
    final rawList = response['transactions'] as List<dynamic>? ?? [];
    return rawList
        .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
