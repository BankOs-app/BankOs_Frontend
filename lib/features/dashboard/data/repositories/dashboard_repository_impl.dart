import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AccountEntity> getAccountSummary() async {
    try {
      final accountModel = await remoteDataSource.getAccountSummary();
      await localDataSource.cacheAccount(accountModel);
      return accountModel;
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedAccount();
      if (cached != null) return cached;
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedAccount();
      if (cached != null) return cached;
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions() async {
    try {
      final transactions = await remoteDataSource.getRecentTransactions();
      await localDataSource.cacheTransactions(transactions);
      return transactions;
    } on ServerException catch (e) {
      final cached = await localDataSource.getCachedTransactions();
      if (cached.isNotEmpty) return cached;
      throw ServerFailure(e.message, e.statusCode);
    } catch (e) {
      final cached = await localDataSource.getCachedTransactions();
      if (cached.isNotEmpty) return cached;
      throw UnexpectedFailure(e.toString());
    }
  }
}
