import '../entities/bank_account_entity.dart';
import '../entities/operation_record_entity.dart';
import '../entities/static_exchange_rate.dart';
import '../repositories/operations_repository.dart';

class CurrencyExchangeParams {
  final BankAccountEntity originAccount;
  final BankAccountEntity destinationAccount;
  final double amount;
  final String? concept;

  const CurrencyExchangeParams({
    required this.originAccount,
    required this.destinationAccount,
    required this.amount,
    this.concept,
  });
}

class CurrencyExchangeUseCase {
  final OperationsRepository repository;

  // Tenant fixed commission for currency conversion
  static const double tenantExchangeCommission = 1.50;

  CurrencyExchangeUseCase(this.repository);

  Future<OperationRecordEntity> call(CurrencyExchangeParams params) async {
    // 1. Validar estados activos de ambas cuentas
    if (!params.originAccount.isActive) {
      throw ArgumentError('La cuenta de origen está inactiva o bloqueada.');
    }
    if (!params.destinationAccount.isActive) {
      throw ArgumentError('La cuenta de destino está inactiva o bloqueada.');
    }

    // 2. Validar mismo tenant
    if (params.originAccount.tenantId != params.destinationAccount.tenantId) {
      throw ArgumentError('Operación multimoneda restringida a cuentas del mismo tenant.');
    }

    // 3. Validar divisas diferentes
    if (params.originAccount.currency == params.destinationAccount.currency) {
      throw ArgumentError('Las cuentas deben manejar divisas diferentes para aplicar conversión.');
    }

    // 4. Validar monto positivo
    if (params.amount <= 0) {
      throw ArgumentError('El monto a convertir debe ser estrictamente positivo (> 0).');
    }

    // 5. Aplicar conversión monetaria utilizando la tabla de tasas estáticas configurada por el tenant
    final staticRate = StaticExchangeRate.getRate(
      params.originAccount.currency,
      params.destinationAccount.currency,
    );

    // 6. Validar fondos en cuenta de origen cubriendo monto + comisión del tenant
    final totalRequired = params.amount + tenantExchangeCommission;
    if (params.originAccount.balance < totalRequired) {
      throw ArgumentError(
        'Fondos insuficientes en ${params.originAccount.currency}. Saldo disponible: ${params.originAccount.formattedBalance}. '
        'Se requiere: \$${totalRequired.toStringAsFixed(2)} (${params.amount} + \$${tenantExchangeCommission.toStringAsFixed(2)} comisión).',
      );
    }

    return repository.currencyExchange(
      originAccountId: params.originAccount.id,
      destinationAccountId: params.destinationAccount.id,
      amount: params.amount,
      staticRate: staticRate,
      concept: params.concept,
    );
  }
}
