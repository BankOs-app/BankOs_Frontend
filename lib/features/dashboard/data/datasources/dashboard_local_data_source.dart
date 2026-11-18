import '../models/account_model.dart';
import '../models/transaction_model.dart';

abstract class DashboardLocalDataSource {
  Future<AccountModel?> getCachedAccount();
  Future<void> cacheAccount(AccountModel account);
  Future<List<TransactionModel>> getCachedTransactions();
  Future<void> cacheTransactions(List<TransactionModel> transactions);
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  AccountModel? _cachedAccount;
  List<TransactionModel> _cachedTransactions = [];

  @override
  Future<AccountModel?> getCachedAccount() async => _cachedAccount;

  @override
  Future<void> cacheAccount(AccountModel account) async {
    _cachedAccount = account;
  }

  @override
  Future<List<TransactionModel>> getCachedTransactions() async =>
      _cachedTransactions;

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    _cachedTransactions = transactions;
  }
}
