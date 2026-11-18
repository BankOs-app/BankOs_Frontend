import 'package:flutter_test/flutter_test.dart';
import 'package:bankos_frontend/core/usecases/usecase.dart';
import 'package:bankos_frontend/features/dashboard/domain/entities/account_entity.dart';
import 'package:bankos_frontend/features/dashboard/domain/entities/transaction_entity.dart';
import 'package:bankos_frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:bankos_frontend/features/dashboard/domain/usecases/get_account_usecase.dart';

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<AccountEntity> getAccountSummary() async {
    return const AccountEntity(
      id: 'acc_001',
      accountNumber: '4829',
      accountType: 'Checking Account',
      balance: 12450000.0,
      currency: 'COP',
      isActive: true,
    );
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions() async {
    return [];
  }
}

void main() {
  late GetAccountUseCase useCase;
  late MockDashboardRepository repository;

  setUp(() {
    repository = MockDashboardRepository();
    useCase = GetAccountUseCase(repository);
  });

  test('should fetch account entity from repository', () async {
    final result = await useCase(const NoParams());

    expect(result.id, 'acc_001');
    expect(result.accountNumber, '4829');
    expect(result.balance, 12450000.0);
    expect(result.currency, 'COP');
  });
}
