import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentTransactionsUseCase
    implements UseCase<List<TransactionEntity>, NoParams> {
  final DashboardRepository repository;

  GetRecentTransactionsUseCase(this.repository);

  @override
  Future<List<TransactionEntity>> call(NoParams params) {
    return repository.getRecentTransactions();
  }
}
