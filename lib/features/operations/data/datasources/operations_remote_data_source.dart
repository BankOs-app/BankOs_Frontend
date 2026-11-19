import '../../../../core/network/dio_client.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/operation_record_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
import '../../domain/entities/static_exchange_rate.dart';

abstract class OperationsRemoteDataSource {
  Future<List<BankAccountEntity>> getAccounts();
  Future<List<OperationRecordEntity>> getHistory();
  Future<List<RegisteredBankEntity>> getBanks();
  Future<List<BankCardEntity>> getCards();

  Future<OperationRecordEntity> deposit({
    required String accountId,
    required double amount,
    String? concept,
  });

  Future<OperationRecordEntity> depositToCard({
    required BankCardEntity card,
    required double amount,
    String? concept,
  });

  Future<OperationRecordEntity> withdraw({
    required String accountId,
    required double amount,
    String? concept,
  });

  Future<OperationRecordEntity> withdrawFromCard({
    required BankCardEntity card,
    required double amount,
    String? concept,
  });

  Future<OperationRecordEntity> internalTransfer({
    required String originAccountId,
    required String destinationAccountId,
    required double amount,
    String? concept,
  });

  Future<OperationRecordEntity> currencyExchange({
    required String originAccountId,
    required String destinationAccountId,
    required double amount,
    required double staticRate,
    String? concept,
  });

  Future<OperationRecordEntity> transferBetweenCards({
    required BankCardEntity originCard,
    required BankCardEntity destinationCard,
    required double amount,
    String? concept,
  });
}

class OperationsRemoteDataSourceImpl implements OperationsRemoteDataSource {
  final DioClient dioClient;

  OperationsRemoteDataSourceImpl({required this.dioClient});

  final List<BankAccountEntity> _accounts = [
    const BankAccountEntity(
      id: 'acc_bankos_global',
      accountNumber: '8820',
      accountType: 'Cuenta Global BankOs',
      balance: 5450.00,
      currency: 'USD',
      isActive: true,
      tenantId: 'tenant_bankos_global',
    ),
    const BankAccountEntity(
      id: 'acc_01',
      accountNumber: '4829',
      accountType: 'Cuenta Débito',
      balance: 24550.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_bancolombia',
    ),
    const BankAccountEntity(
      id: 'acc_01_b',
      accountNumber: '1042',
      accountType: 'Cuenta Débito',
      balance: 5000.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_bancolombia',
    ),
    const BankAccountEntity(
      id: 'acc_02',
      accountNumber: '8812',
      accountType: 'Cuenta Débito',
      balance: 8320.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_davivienda',
    ),
    const BankAccountEntity(
      id: 'acc_02_b',
      accountNumber: '9001',
      accountType: 'Cuenta Débito',
      balance: 12000.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_davivienda',
    ),
    const BankAccountEntity(
      id: 'acc_03',
      accountNumber: '1184',
      accountType: 'Cuenta en Dólares (USD)',
      balance: 1250.00,
      currency: 'USD',
      isActive: true,
      tenantId: 'tenant_chase',
    ),
    const BankAccountEntity(
      id: 'acc_04',
      accountNumber: '3350',
      accountType: 'Cuenta Débito',
      balance: 3400.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_bogota',
    ),
    const BankAccountEntity(
      id: 'acc_05',
      accountNumber: '7721',
      accountType: 'Cuenta Débito',
      balance: 1850.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_bbva',
    ),
    const BankAccountEntity(
      id: 'acc_06_eur',
      accountNumber: '9241',
      accountType: 'Cuenta en Euros (EUR)',
      balance: 1450.00,
      currency: 'EUR',
      isActive: true,
      tenantId: 'tenant_santander_eur',
    ),
  ];

  final List<RegisteredBankEntity> _banks = [
    const RegisteredBankEntity(
      id: 'bank_bankos_global',
      name: 'Cuenta Global BankOs',
      code: 'BOS',
      tenantId: 'tenant_bankos_global',
      currency: 'USD',
      isGlobal: true,
    ),
    const RegisteredBankEntity(
      id: 'bank_bancolombia',
      name: 'Bancolombia',
      code: '007',
      tenantId: 'tenant_bancolombia',
      currency: 'COP',
    ),
    const RegisteredBankEntity(
      id: 'bank_davivienda',
      name: 'Davivienda',
      code: '051',
      tenantId: 'tenant_davivienda',
      currency: 'COP',
    ),
    const RegisteredBankEntity(
      id: 'bank_chase',
      name: 'Chase Bank (EE.UU.)',
      code: '840',
      tenantId: 'tenant_chase',
      currency: 'USD',
    ),
    const RegisteredBankEntity(
      id: 'bank_bogota',
      name: 'Banco de Bogotá',
      code: '001',
      tenantId: 'tenant_bogota',
      currency: 'COP',
    ),
    const RegisteredBankEntity(
      id: 'bank_bbva',
      name: 'BBVA',
      code: '013',
      tenantId: 'tenant_bbva',
      currency: 'COP',
    ),
    const RegisteredBankEntity(
      id: 'bank_santander',
      name: 'Banco Santander (España)',
      code: '049',
      tenantId: 'tenant_santander_eur',
      currency: 'EUR',
    ),
  ];

  late final List<BankCardEntity> _cards = [
    // Cuenta Global BankOs (USD) - Débito y Crédito
    const BankCardEntity(
      id: 'card_bankos_01',
      bankId: 'bank_bankos_global',
      bankName: 'Cuenta Global BankOs',
      cardNumber: '8820',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 5450.00,
      currency: 'USD',
      accountId: 'acc_bankos_global',
    ),
    const BankCardEntity(
      id: 'card_bankos_02',
      bankId: 'bank_bankos_global',
      bankName: 'Cuenta Global BankOs',
      cardNumber: '3301',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.credit,
      availableBalance: 10000.00,
      currency: 'USD',
      accountId: 'acc_bankos_global',
    ),

    // Bancolombia (COP) - Débito y Crédito
    const BankCardEntity(
      id: 'card_col_01',
      bankId: 'bank_bancolombia',
      bankName: 'Bancolombia',
      cardNumber: '4829',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 24550.00,
      currency: 'COP',
      accountId: 'acc_01',
    ),
    const BankCardEntity(
      id: 'card_col_03',
      bankId: 'bank_bancolombia',
      bankName: 'Bancolombia',
      cardNumber: '1042',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.credit,
      availableBalance: 5000.00,
      currency: 'COP',
      accountId: 'acc_01_b',
    ),

    // Davivienda (COP) - Débito y Crédito
    const BankCardEntity(
      id: 'card_davi_01',
      bankId: 'bank_davivienda',
      bankName: 'Davivienda',
      cardNumber: '8812',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 8320.00,
      currency: 'COP',
      accountId: 'acc_02',
    ),
    const BankCardEntity(
      id: 'card_davi_03',
      bankId: 'bank_davivienda',
      bankName: 'Davivienda',
      cardNumber: '9001',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.credit,
      availableBalance: 12000.00,
      currency: 'COP',
      accountId: 'acc_02_b',
    ),

    // Chase Bank (USD) - Débito y Crédito
    const BankCardEntity(
      id: 'card_chase_01',
      bankId: 'bank_chase',
      bankName: 'Chase Bank (EE.UU.)',
      cardNumber: '1184',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 1250.00,
      currency: 'USD',
      accountId: 'acc_03',
    ),
    const BankCardEntity(
      id: 'card_chase_03',
      bankId: 'bank_chase',
      bankName: 'Chase Bank (EE.UU.)',
      cardNumber: '7729',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.credit,
      availableBalance: 3500.00,
      currency: 'USD',
      accountId: 'acc_03',
    ),

    // Banco Santander España (EUR) - Débito y Crédito
    const BankCardEntity(
      id: 'card_sant_01',
      bankId: 'bank_santander',
      bankName: 'Banco Santander (España)',
      cardNumber: '9241',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 1450.00,
      currency: 'EUR',
      accountId: 'acc_06_eur',
    ),
    const BankCardEntity(
      id: 'card_sant_03',
      bankId: 'bank_santander',
      bankName: 'Banco Santander (España)',
      cardNumber: '6120',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.credit,
      availableBalance: 2500.00,
      currency: 'EUR',
      accountId: 'acc_06_eur',
    ),

    // Banco de Bogotá (COP) - Débito y Crédito
    const BankCardEntity(
      id: 'card_bog_01',
      bankId: 'bank_bogota',
      bankName: 'Banco de Bogotá',
      cardNumber: '3350',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 3400.00,
      currency: 'COP',
      accountId: 'acc_04',
    ),
    const BankCardEntity(
      id: 'card_bog_02',
      bankId: 'bank_bogota',
      bankName: 'Banco de Bogotá',
      cardNumber: '8910',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.credit,
      availableBalance: 6000.00,
      currency: 'COP',
      accountId: 'acc_04',
    ),

    // BBVA (COP) - Débito y Crédito
    const BankCardEntity(
      id: 'card_bbva_01',
      bankId: 'bank_bbva',
      bankName: 'BBVA',
      cardNumber: '7721',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 1850.00,
      currency: 'COP',
      accountId: 'acc_05',
    ),
    const BankCardEntity(
      id: 'card_bbva_02',
      bankId: 'bank_bbva',
      bankName: 'BBVA',
      cardNumber: '4412',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.credit,
      availableBalance: 3200.00,
      currency: 'COP',
      accountId: 'acc_05',
    ),
  ];

  final List<OperationRecordEntity> _history = [
    // Cuenta Global BankOs History
    OperationRecordEntity(
      id: 'op_bos_001',
      type: OperationType.deposit,
      title: 'Consignación a Cuenta Global',
      description: 'Abono desde cuenta personal Bancolombia (COP)',
      amount: 500.00,
      currency: 'USD',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      originAccountId: 'acc_bankos_global',
    ),
    OperationRecordEntity(
      id: 'op_bos_002',
      type: OperationType.withdrawal,
      title: 'Retiro hacia Santander (EUR)',
      description: 'Traspaso internacional a cuenta personal',
      amount: 150.00,
      currency: 'USD',
      fee: 1.5,
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      originAccountId: 'acc_bankos_global',
    ),
    OperationRecordEntity(
      id: 'op_bos_003',
      type: OperationType.internalTransfer,
      title: 'Transferencia recibida',
      description: 'Pago global de honorarios',
      amount: 5100.00,
      currency: 'USD',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      originAccountId: 'acc_bankos_global',
    ),
    // Bancolombia Tenant History
    OperationRecordEntity(
      id: 'op_col_001',
      type: OperationType.deposit,
      title: 'Supermercado',
      description: 'Transferencia recibida',
      amount: 50.00,
      currency: 'COP',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      originAccountId: 'acc_01',
    ),
    OperationRecordEntity(
      id: 'op_col_002',
      type: OperationType.internalTransfer,
      title: 'Transferencia recibida',
      description: 'Abono nómina empresarial',
      amount: 24550.00,
      currency: 'COP',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      originAccountId: 'acc_01',
    ),
    // Davivienda Tenant History
    OperationRecordEntity(
      id: 'op_dav_001',
      type: OperationType.withdrawal,
      title: 'Pago servicios públicos',
      description: 'Débito automático Enel',
      amount: 35.00,
      currency: 'COP',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      originAccountId: 'acc_02',
    ),
    OperationRecordEntity(
      id: 'op_dav_002',
      type: OperationType.deposit,
      title: 'Depósito en Cajero',
      description: 'Abono en efectivo Davivienda',
      amount: 8320.00,
      currency: 'COP',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      originAccountId: 'acc_02',
    ),
    // Chase Bank (USD) Tenant History
    OperationRecordEntity(
      id: 'op_chase_001',
      type: OperationType.deposit,
      title: 'Direct Deposit Payroll',
      description: 'US Employer Payroll',
      amount: 1250.00,
      currency: 'USD',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      originAccountId: 'acc_03',
    ),
    OperationRecordEntity(
      id: 'op_chase_002',
      type: OperationType.withdrawal,
      title: 'Amazon Web Services',
      description: 'Cloud subscription payment',
      amount: 15.00,
      currency: 'USD',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      originAccountId: 'acc_03',
    ),
    // Banco de Bogotá Tenant History
    OperationRecordEntity(
      id: 'op_bog_001',
      type: OperationType.withdrawal,
      title: 'Retiro Cajero Red ATH',
      description: 'Cajero Calle 72',
      amount: 100.00,
      currency: 'COP',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      originAccountId: 'acc_04',
    ),
    // BBVA Tenant History
    OperationRecordEntity(
      id: 'op_bbva_001',
      type: OperationType.deposit,
      title: 'Abono Quincenal',
      description: 'Pago honorarios profesionales',
      amount: 850.00,
      currency: 'COP',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      originAccountId: 'acc_05',
    ),
    // Banco Santander Tenant History (EUR)
    OperationRecordEntity(
      id: 'op_sant_001',
      type: OperationType.deposit,
      title: 'Transferencia SEPA',
      description: 'Ingreso de fondos en Euros',
      amount: 1450.00,
      currency: 'EUR',
      fee: 0.0,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      originAccountId: 'acc_06_eur',
    ),
  ];

  @override
  Future<List<BankAccountEntity>> getAccounts() async {
    return List.unmodifiable(_accounts);
  }

  @override
  Future<List<RegisteredBankEntity>> getBanks() async {
    return List.unmodifiable(_banks);
  }

  @override
  Future<List<BankCardEntity>> getCards() async {
    return List.unmodifiable(_cards);
  }

  @override
  Future<List<OperationRecordEntity>> getHistory() async {
    return List.unmodifiable(_history);
  }

  @override
  Future<OperationRecordEntity> deposit({
    required String accountId,
    required double amount,
    String? concept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx != -1) {
      final acc = _accounts[idx];
      _accounts[idx] = acc.copyWith(balance: acc.balance + amount);

      final record = OperationRecordEntity(
        id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.deposit,
        title: 'Depósito a cuenta',
        description: concept ?? 'Abono de fondos exitoso',
        amount: amount,
        currency: acc.currency,
        timestamp: DateTime.now(),
        originAccountId: accountId,
      );
      _history.insert(0, record);
      return record;
    }
    throw Exception('Cuenta no encontrada.');
  }

  @override
  Future<OperationRecordEntity> depositToCard({
    required BankCardEntity card,
    required double amount,
    String? concept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final cardIdx = _cards.indexWhere((c) => c.id == card.id);
    if (cardIdx != -1) {
      final currentCard = _cards[cardIdx];
      if (amount <= 0) {
        throw ArgumentError('El monto debe ser estrictamente positivo.');
      }

      _cards[cardIdx] = currentCard.copyWith(
        availableBalance: currentCard.availableBalance + amount,
      );

      // Credit underlying account if exists
      final accIdx =
          _accounts.indexWhere((a) => a.id == currentCard.accountId);
      if (accIdx != -1) {
        final acc = _accounts[accIdx];
        _accounts[accIdx] = acc.copyWith(balance: acc.balance + amount);
      }

      String title;
      String defaultDesc;
      switch (currentCard.cardType) {
        case BankCardType.credit:
          title = 'Abono Cuenta Crédito';
          defaultDesc = 'Pago / Liberación de cupo (${currentCard.maskedCardNumber})';
          break;
        case BankCardType.debit:
          title = 'Depósito Cuenta Débito';
          defaultDesc = 'Abono de fondos propios (${currentCard.maskedCardNumber})';
          break;
      }

      final record = OperationRecordEntity(
        id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.deposit,
        title: '$title - ${currentCard.bankName}',
        description: concept != null && concept.isNotEmpty ? concept : defaultDesc,
        amount: amount,
        currency: currentCard.currency,
        timestamp: DateTime.now(),
        originAccountId: currentCard.accountId,
      );
      _history.insert(0, record);
      return record;
    }
    throw Exception('Tarjeta no encontrada.');
  }

  @override
  Future<OperationRecordEntity> withdraw({
    required String accountId,
    required double amount,
    String? concept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final idx = _accounts.indexWhere((a) => a.id == accountId);
    if (idx != -1) {
      final acc = _accounts[idx];
      _accounts[idx] = acc.copyWith(balance: acc.balance - amount);

      final record = OperationRecordEntity(
        id: 'wdr_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.withdrawal,
        title: 'Retiro de cuenta',
        description: concept ?? 'Débito de fondos exitoso',
        amount: amount,
        currency: acc.currency,
        timestamp: DateTime.now(),
        originAccountId: accountId,
      );
      _history.insert(0, record);
      return record;
    }
    throw Exception('Cuenta no encontrada.');
  }

  @override
  Future<OperationRecordEntity> withdrawFromCard({
    required BankCardEntity card,
    required double amount,
    String? concept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final cardIdx = _cards.indexWhere((c) => c.id == card.id);
    if (cardIdx != -1) {
      final currentCard = _cards[cardIdx];
      if (amount <= 0) {
        throw ArgumentError('El monto debe ser estrictamente positivo.');
      }
      if (currentCard.availableBalance < amount) {
        throw ArgumentError('Saldo insuficiente en la tarjeta seleccionada.');
      }

      _cards[cardIdx] = currentCard.copyWith(
        availableBalance: currentCard.availableBalance - amount,
      );

      // Debit underlying account if exists
      final accIdx = _accounts.indexWhere((a) => a.id == currentCard.accountId);
      if (accIdx != -1) {
        final acc = _accounts[accIdx];
        _accounts[accIdx] = acc.copyWith(balance: acc.balance - amount);
      }

      String title;
      String defaultDesc;
      switch (currentCard.cardType) {
        case BankCardType.credit:
          title = 'Avance Cuenta Crédito';
          defaultDesc = 'Avance de efectivo contra cupo (${currentCard.maskedCardNumber})';
          break;
        case BankCardType.debit:
          title = 'Retiro Cuenta Débito';
          defaultDesc = 'Retiro de fondos propios (${currentCard.maskedCardNumber})';
          break;
      }

      final record = OperationRecordEntity(
        id: 'wdr_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.withdrawal,
        title: '$title - ${currentCard.bankName}',
        description: concept != null && concept.isNotEmpty ? concept : defaultDesc,
        amount: amount,
        currency: currentCard.currency,
        timestamp: DateTime.now(),
        originAccountId: currentCard.accountId,
      );
      _history.insert(0, record);
      return record;
    }
    throw Exception('Tarjeta no encontrada.');
  }

  @override
  Future<OperationRecordEntity> internalTransfer({
    required String originAccountId,
    required String destinationAccountId,
    required double amount,
    String? concept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    const fee = 2.50;
    final origIdx = _accounts.indexWhere((a) => a.id == originAccountId);
    final destIdx = _accounts.indexWhere((a) => a.id == destinationAccountId);

    if (origIdx == -1 || destIdx == -1) {
      throw Exception('Una o ambas cuentas no existen.');
    }

    final orig = _accounts[origIdx];
    final dest = _accounts[destIdx];

    _accounts[origIdx] = orig.copyWith(balance: orig.balance - (amount + fee));
    _accounts[destIdx] = dest.copyWith(balance: dest.balance + amount);

    final record = OperationRecordEntity(
      id: 'trf_${DateTime.now().millisecondsSinceEpoch}',
      type: OperationType.internalTransfer,
      title: 'Transferencia interna',
      description: concept ?? 'Transferencia a ${dest.maskedAccountNumber}',
      amount: amount,
      currency: orig.currency,
      fee: fee,
      timestamp: DateTime.now(),
      originAccountId: originAccountId,
      destinationAccountId: destinationAccountId,
    );
    _history.insert(0, record);
    return record;
  }

  @override
  Future<OperationRecordEntity> currencyExchange({
    required String originAccountId,
    required String destinationAccountId,
    required double amount,
    required double staticRate,
    String? concept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final origIdx = _accounts.indexWhere((a) => a.id == originAccountId);
    final destIdx = _accounts.indexWhere((a) => a.id == destinationAccountId);

    if (origIdx == -1 || destIdx == -1) {
      throw Exception('Cuentas no encontradas.');
    }

    final orig = _accounts[origIdx];
    final dest = _accounts[destIdx];
    final convertedAmount = amount * staticRate;

    _accounts[origIdx] = orig.copyWith(balance: orig.balance - amount);
    _accounts[destIdx] = dest.copyWith(balance: dest.balance + convertedAmount);

    final record = OperationRecordEntity(
      id: 'exc_${DateTime.now().millisecondsSinceEpoch}',
      type: OperationType.currencyExchange,
      title: 'Conversión de divisas',
      description: concept ?? '${orig.currency} -> ${dest.currency}',
      amount: amount,
      currency: orig.currency,
      timestamp: DateTime.now(),
      originAccountId: originAccountId,
      destinationAccountId: destinationAccountId,
    );
    _history.insert(0, record);
    return record;
  }

  @override
  Future<OperationRecordEntity> transferBetweenCards({
    required BankCardEntity originCard,
    required BankCardEntity destinationCard,
    required double amount,
    String? concept,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final origIdx = _cards.indexWhere((c) => c.id == originCard.id);
    final destIdx = _cards.indexWhere((c) => c.id == destinationCard.id);

    if (origIdx == -1 || destIdx == -1) {
      throw Exception('Una o ambas tarjetas no existen.');
    }

    final orig = _cards[origIdx];
    final dest = _cards[destIdx];
    const fee = 2.50;
    final totalDebit = amount + fee;

    if (orig.availableBalance < totalDebit) {
      throw ArgumentError(
        'Saldo insuficiente en ${orig.bankName}. Disponible: ${orig.formattedBalance}. '
        'Requerido: \$${totalDebit.toStringAsFixed(2)} ($amount + \$${fee.toStringAsFixed(2)} comisión).',
      );
    }

    // Calcular monto acreditado considerando tasa estática si difieren divisas
    double creditedAmount = amount;
    if (orig.currency != dest.currency) {
      final rate = StaticExchangeRate.getRate(orig.currency, dest.currency);
      creditedAmount = amount * rate;
    }

    _cards[origIdx] =
        orig.copyWith(availableBalance: orig.availableBalance - totalDebit);
    _cards[destIdx] =
        dest.copyWith(availableBalance: dest.availableBalance + creditedAmount);

    // Actualizar cuentas subyacentes
    final origAccIdx = _accounts.indexWhere((a) => a.id == orig.accountId);
    if (origAccIdx != -1) {
      final acc = _accounts[origAccIdx];
      _accounts[origAccIdx] = acc.copyWith(balance: acc.balance - totalDebit);
    }
    final destAccIdx = _accounts.indexWhere((a) => a.id == dest.accountId);
    if (destAccIdx != -1) {
      final acc = _accounts[destAccIdx];
      _accounts[destAccIdx] =
          acc.copyWith(balance: acc.balance + creditedAmount);
    }

    final record = OperationRecordEntity(
      id: 'trf_${DateTime.now().millisecondsSinceEpoch}',
      type: orig.currency != dest.currency
          ? OperationType.currencyExchange
          : OperationType.internalTransfer,
      title: orig.currency != dest.currency
          ? 'Conversión multimoneda'
          : 'Transferencia interna',
      description: concept ??
          'Traspaso de ${orig.bankName} (${orig.maskedCardNumber}) a ${dest.bankName} (${dest.maskedCardNumber})',
      amount: amount,
      currency: orig.currency,
      fee: fee,
      timestamp: DateTime.now(),
      originAccountId: orig.accountId,
      destinationAccountId: dest.accountId,
    );
    _history.insert(0, record);
    return record;
  }
}
