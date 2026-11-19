import '../entities/bank_account_entity.dart';
import '../entities/operation_record_entity.dart';
import '../repositories/operations_repository.dart';

class WithdrawParams {
  final BankAccountEntity account;
  final double amount;
  final String? concept;

  const WithdrawParams({
    required this.account,
    required this.amount,
    this.concept,
  });
}

class WithdrawUseCase {
  final OperationsRepository repository;

  WithdrawUseCase(this.repository);

  Future<OperationRecordEntity> call(WithdrawParams params) async {
    // 1. Validar que la cuenta esté activa
    if (!params.account.isActive) {
      throw ArgumentError('La cuenta ${params.account.accountNumber} se encuentra inactiva o bloqueada.');
    }

    // 2. Validar que el monto sea positivo
    if (params.amount <= 0) {
      throw ArgumentError('El monto a retirar debe ser estrictamente positivo (> 0).');
    }

    // 3. Validar que el saldo sea suficiente
    if (params.account.balance < params.amount) {
      throw ArgumentError(
        'Saldo insuficiente. Saldo disponible: ${params.account.formattedBalance}, monto solicitado: \$${params.amount.toStringAsFixed(2)} ${params.account.currency}.',
      );
    }

    return repository.withdraw(
      accountId: params.account.id,
      amount: params.amount,
      concept: params.concept,
    );
  }
}
