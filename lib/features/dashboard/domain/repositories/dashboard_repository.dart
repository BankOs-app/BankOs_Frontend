import '../entities/account_entity.dart';
import '../entities/transaction_entity.dart';

abstract class DashboardRepository {
  Future<AccountEntity> getAccountSummary();
  Future<List<TransactionEntity>> getRecentTransactions();
}
