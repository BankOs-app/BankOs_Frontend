import '../entities/bank_account_entity.dart';
import '../entities/operation_record_entity.dart';
import '../repositories/operations_repository.dart';

class DepositParams {
  final BankAccountEntity account;
  final double amount;
  final String? concept;

  const DepositParams({
    required this.account,
    required this.amount,
    this.concept,
  });
}

class DepositUseCase {
  final OperationsRepository repository;

  DepositUseCase(this.repository);

  Future<OperationRecordEntity> call(DepositParams params) async {
    // 1. Validar que la cuenta esté activa
    if (!params.account.isActive) {
      throw ArgumentError('La cuenta ${params.account.accountNumber} se encuentra inactiva o bloqueada.');
    }

    // 2. Validar que el monto sea estrictamente positivo
    if (params.amount <= 0) {
      throw ArgumentError('El monto a depositar debe ser estrictamente positivo (> 0).');
    }

    return repository.deposit(
      accountId: params.account.id,
      amount: params.amount,
      concept: params.concept,
    );
  }
}
