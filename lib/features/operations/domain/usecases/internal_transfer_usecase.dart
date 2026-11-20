import '../entities/bank_account_entity.dart';
import '../entities/operation_record_entity.dart';
import '../repositories/operations_repository.dart';

class InternalTransferParams {
  final BankAccountEntity originAccount;
  final BankAccountEntity destinationAccount;
  final double amount;
  final String? concept;

  const InternalTransferParams({
    required this.originAccount,
    required this.destinationAccount,
    required this.amount,
    this.concept,
  });
}

class InternalTransferUseCase {
  final OperationsRepository repository;

  // Tenant fixed commission for internal transfers
  static const double tenantCommission = 2.50;

  InternalTransferUseCase(this.repository);

  Future<OperationRecordEntity> call(InternalTransferParams params) async {
    // 1. Validar existencia y que no sean la misma cuenta
    if (params.originAccount.id == params.destinationAccount.id) {
      throw ArgumentError('La cuenta de origen y destino no pueden ser la misma.');
    }

    // 2. Validar estados activos de ambas cuentas
    if (!params.originAccount.isActive) {
      throw ArgumentError('La cuenta de origen (${params.originAccount.maskedAccountNumber}) está inactiva o bloqueada.');
    }
    if (!params.destinationAccount.isActive) {
      throw ArgumentError('La cuenta de destino (${params.destinationAccount.maskedAccountNumber}) está inactiva o bloqueada.');
    }

    // 3. Validar mismo tenant
    if (params.originAccount.tenantId != params.destinationAccount.tenantId) {
      throw ArgumentError('Las transferencias internas solo están permitidas entre cuentas del mismo tenant.');
    }

    // 4. Validar monto estrictamente positivo
    if (params.amount <= 0) {
      throw ArgumentError('El monto de la transferencia debe ser estrictamente positivo (> 0).');
    }

    // 5. Aplicar automáticamente la comisión configurada por el tenant
    final totalRequired = params.amount + tenantCommission;

    // 6. Validar fondos suficientes en el origen para cubrir monto + comisión
    if (params.originAccount.balance < totalRequired) {
      throw ArgumentError(
        'Fondos insuficientes en la cuenta de origen. Saldo disponible: ${params.originAccount.formattedBalance}. '
        'Se requiere: \$${totalRequired.toStringAsFixed(2)} (${params.amount} + \$${tenantCommission.toStringAsFixed(2)} de comisión del tenant).',
      );
    }

    return repository.internalTransfer(
      originAccountId: params.originAccount.id,
      destinationAccountId: params.destinationAccount.id,
      amount: params.amount,
      concept: params.concept,
    );
  }
}
