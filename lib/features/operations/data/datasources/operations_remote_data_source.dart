import 'package:dio/dio.dart';

import '../../../../core/errors/user_facing_error.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
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
  Future<RegisteredBankEntity> registerTenant(RegisteredBankEntity bank);

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

  Future<void> updateBankBranding({
    required String slug,
    required String primaryColor,
    required String accentColor,
    required String logoUrl,
  });
}

class OperationsRemoteDataSourceImpl implements OperationsRemoteDataSource {
  final DioClient dioClient;

  OperationsRemoteDataSourceImpl({required this.dioClient});

  // Cuentas locales de inicialización y contingencia
  final List<BankAccountEntity> _accounts = [
    const BankAccountEntity(
      id: 'acc_01',
      accountNumber: '7007007001',
      accountType: 'Cuenta Débito',
      balance: 8000000.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_banco_lombia',
    ),
    const BankAccountEntity(
      id: 'acc_bogota_01',
      accountNumber: '1001001001',
      accountType: 'Cuenta Débito',
      balance: 5000000.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_banco_bogota',
    ),
    const BankAccountEntity(
      id: 'acc_bogota_02',
      accountNumber: '1001001002',
      accountType: 'Cuenta en Dólares (USD)',
      balance: 1500.00,
      currency: 'USD',
      isActive: true,
      tenantId: 'tenant_banco_bogota',
    ),
    const BankAccountEntity(
      id: 'acc_santander_01',
      accountNumber: '9009009001',
      accountType: 'Cuenta en Dólares (USD)',
      balance: 3500.00,
      currency: 'USD',
      isActive: true,
      tenantId: 'tenant_banco_santander',
    ),
    const BankAccountEntity(
      id: 'acc_nu_01',
      accountNumber: '8008008001',
      accountType: 'Cuenta Débito',
      balance: 3500000.00,
      currency: 'COP',
      isActive: true,
      tenantId: 'tenant_banco_nu',
    ),
    const BankAccountEntity(
      id: 'acc_bankos_01',
      accountNumber: '1001001000',
      accountType: 'Cuenta Multidivisa Global (USD)',
      balance: 150000.00,
      currency: 'USD',
      isActive: true,
      tenantId: 'tenant_bankos_global',
    ),
  ];

  // Instituciones registradas iniciales
  final List<RegisteredBankEntity> _banks = [
    const RegisteredBankEntity(
      id: 'bank_bankos_global',
      name: 'Cuenta Global BankOs',
      code: 'BOS',
      tenantId: 'tenant_bankos_global',
      currency: 'USD',
      isGlobal: true,
      primaryColorHex: '#031633',
      accentColorHex: '#6DA5FA',
      logoKey: 'bankos',
    ),
    const RegisteredBankEntity(
      id: '4f2a0415-2697-42d7-878d-ab67a1f6a657',
      name: 'Bancolombia',
      code: 'banco-lombia',
      tenantId: 'tenant_banco_lombia',
      currency: 'COP',
      primaryColorHex: '#000000',
      accentColorHex: '#FDDA24',
      logoKey: 'bancolombia',
    ),
    const RegisteredBankEntity(
      id: '11111111-1111-4111-8111-111111111111',
      name: 'Banco de Bogotá',
      code: 'banco-bogota',
      tenantId: 'tenant_banco_bogota',
      currency: 'COP',
      primaryColorHex: '#002D72',
      accentColorHex: '#004BB1',
      logoKey: 'banco-bogota',
    ),
    const RegisteredBankEntity(
      id: '22222222-2222-4222-8222-222222222222',
      name: 'Banco Santander',
      code: 'banco-santander',
      tenantId: 'tenant_banco_santander',
      currency: 'USD',
      primaryColorHex: '#EC0000',
      accentColorHex: '#CC0000',
      logoKey: 'banco-santander',
    ),
    const RegisteredBankEntity(
      id: '47130a5f-3368-4a0b-ab77-0982b6a07a96',
      name: 'Banco de NU',
      code: 'banco-nu',
      tenantId: 'tenant_banco_nu',
      currency: 'COP',
      primaryColorHex: '#820AD1',
      accentColorHex: '#9B3FE6',
      logoKey: 'banco-nu',
    ),
    const RegisteredBankEntity(
      id: 'e3a4a8cc-5551-400b-beb5-6b5ced30c7e0',
      name: 'Banco de Occidente',
      code: 'banco-occidente',
      tenantId: 'tenant_banco_occidente',
      currency: 'COP',
      primaryColorHex: '#0A2540',
      accentColorHex: '#0052FF',
      logoKey: 'bankos',
    ),
  ];

  late final List<BankCardEntity> _cards = [
    const BankCardEntity(
      id: 'card_col_01',
      bankId: '4f2a0415-2697-42d7-878d-ab67a1f6a657',
      bankName: 'Bancolombia',
      cardNumber: '7007007001',
      cardHolder: 'Alejandro Morales',
      cardType: BankCardType.debit,
      availableBalance: 8000000.00,
      currency: 'COP',
      accountId: 'acc_01',
    ),
    const BankCardEntity(
      id: 'card_bogota_01',
      bankId: '11111111-1111-4111-8111-111111111111',
      bankName: 'Banco de Bogotá',
      cardNumber: '1001001001',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 5000000.00,
      currency: 'COP',
      accountId: 'acc_bogota_01',
    ),
    const BankCardEntity(
      id: 'card_sant_01',
      bankId: '22222222-2222-4222-8222-222222222222',
      bankName: 'Banco Santander',
      cardNumber: '9009009001',
      cardHolder: 'John Smith',
      cardType: BankCardType.debit,
      availableBalance: 3500.00,
      currency: 'USD',
      accountId: 'acc_santander_01',
    ),
    const BankCardEntity(
      id: 'card_nu_01',
      bankId: '47130a5f-3368-4a0b-ab77-0982b6a07a96',
      bankName: 'Banco de NU',
      cardNumber: '8008008001',
      cardHolder: 'Catalina Restrepo',
      cardType: BankCardType.debit,
      availableBalance: 3500000.00,
      currency: 'COP',
      accountId: 'acc_nu_01',
    ),
    const BankCardEntity(
      id: 'card_occ_01',
      bankId: 'e3a4a8cc-5551-400b-beb5-6b5ced30c7e0',
      bankName: 'Banco de Occidente',
      cardNumber: '5005005001',
      cardHolder: 'Carlos Gómez',
      cardType: BankCardType.debit,
      availableBalance: 4200000.00,
      currency: 'COP',
      accountId: 'acc_occ_01',
    ),
    const BankCardEntity(
      id: 'card_bos_01',
      bankId: 'bank_bankos_global',
      bankName: 'Cuenta Global BankOs',
      cardNumber: '1001001000',
      cardHolder: 'Luigui Garizado',
      cardType: BankCardType.debit,
      availableBalance: 50000.00,
      currency: 'USD',
      accountId: 'acc_bankos_01',
    ),
  ];

  final List<OperationRecordEntity> _history = [
    // Cuenta Global BankOs
    OperationRecordEntity(
      id: 'tx_bos_01',
      type: OperationType.deposit,
      title: 'Capitalización BaaS Multi-tenant',
      description:
          'Aporte de liquidez centralizada para operaciones interbancarias',
      amount: 50000.00,
      currency: 'USD',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      originAccountId: 'acc_bankos_01',
    ),
    OperationRecordEntity(
      id: 'tx_bos_02',
      type: OperationType.internalTransfer,
      title: 'Liquidación Compensación ACH',
      description: 'Transferencia de compensación neta hacia Banco de Bogotá',
      amount: 12500.00,
      currency: 'USD',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      originAccountId: 'acc_bankos_01',
      destinationAccountId: 'acc_bogota_02',
    ),
    OperationRecordEntity(
      id: 'tx_bos_03',
      type: OperationType.deposit,
      title: 'Recarga Gateway API Developer',
      description: 'Cobro de facturación de microservicios BaaS API',
      amount: 8400.00,
      currency: 'USD',
      timestamp: DateTime.now().subtract(const Duration(hours: 7)),
      originAccountId: 'acc_bankos_01',
    ),
    OperationRecordEntity(
      id: 'tx_bos_04',
      type: OperationType.withdrawal,
      title: 'Retiro Arbitraje Forex',
      description: 'Desembolso hacia tesorería internacional',
      amount: 3200.00,
      currency: 'USD',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      originAccountId: 'acc_bankos_01',
    ),
    // Bancolombia
    OperationRecordEntity(
      id: 'tx_col_01',
      type: OperationType.deposit,
      title: 'Depósito Nómina Corporativa',
      description: 'Abono quincenal nómina empresarial Tech Corp',
      amount: 4500000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      originAccountId: 'acc_01',
    ),
    OperationRecordEntity(
      id: 'tx_col_02',
      type: OperationType.withdrawal,
      title: 'Retiro Cajero Automático',
      description: 'Dispensación en Cajero Servibanca Unicentro',
      amount: 350000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      originAccountId: 'acc_01',
    ),
    OperationRecordEntity(
      id: 'tx_col_03',
      type: OperationType.internalTransfer,
      title: 'Transferencia ACH Transfiya',
      description: 'Envío de dinero interbancario hacia Nu',
      amount: 1200000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      originAccountId: 'acc_01',
      destinationAccountId: 'acc_nu_01',
    ),
    OperationRecordEntity(
      id: 'tx_col_04',
      type: OperationType.deposit,
      title: 'Pago Factura Proveedores',
      description: 'Transferencia recibida por servicios consultoría',
      amount: 2800000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      originAccountId: 'acc_01',
    ),
    // Banco de Bogotá
    OperationRecordEntity(
      id: 'tx_bog_01',
      type: OperationType.deposit,
      title: 'Liquidación Fondos Fiduciaria',
      description: 'Rendimiento fiduciario Fiduciaria Bogotá',
      amount: 3000000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      originAccountId: 'acc_bogota_01',
    ),
    OperationRecordEntity(
      id: 'tx_bog_02',
      type: OperationType.withdrawal,
      title: 'Retiro Cajero Red AVAL',
      description: 'Retiro sin tarjeta con token OTP',
      amount: 200000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      originAccountId: 'acc_bogota_01',
    ),
    OperationRecordEntity(
      id: 'tx_bog_03',
      type: OperationType.internalTransfer,
      title: 'Transferencia Pago Servicios Públicos',
      description: 'Pago mensual acueducto y energía',
      amount: 450000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      originAccountId: 'acc_bogota_01',
    ),
    // Banco Santander
    OperationRecordEntity(
      id: 'tx_san_01',
      type: OperationType.deposit,
      title: 'Remesa Internacional SWIFT',
      description: 'Abono directo cuenta internacional Santander',
      amount: 2500.00,
      currency: 'USD',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      originAccountId: 'acc_santander_01',
    ),
    OperationRecordEntity(
      id: 'tx_san_02',
      type: OperationType.internalTransfer,
      title: 'Transferencia Comercio Exterior',
      description: 'Pago proveedor de insumos Miami',
      amount: 850.00,
      currency: 'USD',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      originAccountId: 'acc_santander_01',
    ),
    OperationRecordEntity(
      id: 'tx_san_03',
      type: OperationType.withdrawal,
      title: 'Retiro Cajero Santander Global',
      description: 'Dispensación efectivo ATM internacional',
      amount: 300.00,
      currency: 'USD',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      originAccountId: 'acc_santander_01',
    ),
    // Banco Nu
    OperationRecordEntity(
      id: 'tx_nu_01',
      type: OperationType.deposit,
      title: 'Recarga PSE Cuenta Nu',
      description: 'Abono instantáneo desde portal de pagos',
      amount: 1200000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      originAccountId: 'acc_nu_01',
    ),
    OperationRecordEntity(
      id: 'tx_nu_02',
      type: OperationType.withdrawal,
      title: 'Retiro Cajero Servibanca',
      description: 'Retiro débito cajero aliado Nu',
      amount: 150000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      originAccountId: 'acc_nu_01',
    ),
    OperationRecordEntity(
      id: 'tx_nu_03',
      type: OperationType.deposit,
      title: 'Rendimiento Cajita Nu 13% E.A.',
      description: 'Interés diario acreditado en cajita de ahorros',
      amount: 85000.00,
      currency: 'COP',
      timestamp: DateTime.now().subtract(const Duration(hours: 18)),
      originAccountId: 'acc_nu_01',
    ),
  ];

  String _resolveTenantSlug(String? accountIdentifier) {
    if (accountIdentifier != null) {
      final acc = _accounts
          .where(
            (a) =>
                a.id == accountIdentifier ||
                a.accountNumber == accountIdentifier ||
                a.accountNumber.endsWith(accountIdentifier),
          )
          .firstOrNull;
      if (acc != null) {
        final bank = _banks
            .where(
              (candidate) =>
                  candidate.id == acc.tenantId ||
                  candidate.tenantId == acc.tenantId,
            )
            .firstOrNull;
        if (bank != null) {
          final s = bank.slug.toLowerCase();
          return (s == 'bos' || s == 'bankos') ? 'banco-lombia' : bank.slug;
        }
        if (acc.tenantId.contains('santander')) return 'banco-santander';
        if (acc.tenantId.contains('bogota')) return 'banco-bogota';
        if (acc.tenantId.contains('nu')) return 'banco-nu';
        return 'banco-lombia';
      }

      final card = _cards
          .where(
            (c) =>
                c.id == accountIdentifier ||
                c.cardNumber == accountIdentifier ||
                c.accountId == accountIdentifier,
          )
          .firstOrNull;
      if (card != null) {
        final bank = _banks.where((b) => b.id == card.bankId).firstOrNull;
        if (bank != null) {
          final s = bank.slug.toLowerCase();
          return (s == 'bos' || s == 'bankos') ? 'banco-lombia' : bank.slug;
        }
        final nameLower = card.bankName.toLowerCase();
        if (nameLower.contains('nu')) return 'banco-nu';
        if (nameLower.contains('bogota')) return 'banco-bogota';
        if (nameLower.contains('santander')) return 'banco-santander';
        return 'banco-lombia';
      }
    }

    if (AuthRemoteDataSourceImpl.activeTenantSlug != null &&
        AuthRemoteDataSourceImpl.activeTenantSlug!.isNotEmpty) {
      final active = AuthRemoteDataSourceImpl.activeTenantSlug!.toLowerCase();
      if (active == 'bos' || active == 'bankos') return 'banco-lombia';
      return AuthRemoteDataSourceImpl.activeTenantSlug!;
    }

    return 'banco-lombia';
  }

  void _syncCardsWithAccounts() {
    for (int i = 0; i < _cards.length; i++) {
      final card = _cards[i];
      final acc = _accounts
          .where(
            (a) =>
                a.id == card.accountId ||
                a.accountNumber == card.cardNumber ||
                a.accountNumber.endsWith(card.cardNumber),
          )
          .firstOrNull;
      if (acc != null) {
        _cards[i] = card.copyWith(
          availableBalance: acc.balance,
          cardNumber: acc.accountNumber,
          accountId: acc.id,
        );
      }
    }
  }

  @override
  Future<List<RegisteredBankEntity>> getBanks() async {
    try {
      final response = await dioClient.get(ApiEndpoints.tenants);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        if (list.isNotEmpty) {
          final mappedBanks = list.map((item) {
            final m = item as Map<String, dynamic>;
            final slug = m['slug'] as String? ?? '';
            return RegisteredBankEntity(
              id: m['id'] as String? ?? slug,
              name: m['name'] as String? ?? slug,
              code: m['code'] as String? ?? slug.toUpperCase(),
              assignedSlug: slug,
              assignedSubdomain: m['subdomain'] as String? ?? '$slug.bankos.io',
              tenantId: m['schemaName'] as String? ?? slug,
              currency: m['primaryCurrency'] as String? ?? 'COP',
              isGlobal: slug.contains('global'),
              primaryColorHex:
                  m['primaryColor'] as String? ??
                  (slug.contains('lombia')
                      ? '#000000'
                      : (slug.contains('bogota')
                            ? '#002D72'
                            : (slug.contains('santander')
                                  ? '#EC0000'
                                  : (slug.contains('nu')
                                        ? '#820AD1'
                                        : '#0A2540')))),
              accentColorHex:
                  m['accentColor'] as String? ??
                  (slug.contains('lombia')
                      ? '#FDDA24'
                      : (slug.contains('bogota')
                            ? '#004BB1'
                            : (slug.contains('santander')
                                  ? '#CC0000'
                                  : (slug.contains('nu')
                                        ? '#9B3FE6'
                                        : '#0052FF')))),
              logoKey:
                  m['logoUrl'] as String? ??
                  (slug.contains('lombia')
                      ? 'bancolombia'
                      : (slug.contains('bogota')
                            ? 'banco-bogota'
                            : (slug.contains('santander')
                                  ? 'banco-santander'
                                  : (slug.contains('nu')
                                        ? 'banco-nu'
                                        : 'bankos')))),
            );
          }).toList();

          if (mappedBanks.isNotEmpty) {
            _banks.clear();
            _banks.add(
              const RegisteredBankEntity(
                id: 'bank_bankos_global',
                name: 'Cuenta Global BankOs',
                code: 'BOS',
                tenantId: 'tenant_bankos_global',
                currency: 'USD',
                isGlobal: true,
                primaryColorHex: '#031633',
                accentColorHex: '#6DA5FA',
                logoKey: 'bankos',
              ),
            );
            _banks.addAll(mappedBanks);
            return List.unmodifiable(_banks);
          }
        }
      }
    } catch (_) {}
    return List.unmodifiable(_banks);
  }

  @override
  Future<RegisteredBankEntity> registerTenant(RegisteredBankEntity bank) async {
    final slug = bank.code.toLowerCase().replaceAll('_', '-');
    final response = await dioClient.post(
      ApiEndpoints.tenants,
      data: {
        'name': bank.name,
        'code': bank.code.toUpperCase(),
        'subdomain': bank.subdomain.toLowerCase(),
        'slug': slug,
        'primaryCurrency': bank.currency,
        'maxTransactionAmount': '50000000.00',
        'feeType': 'FIXED',
        'feeValue': '2500.0000',
      },
    );
    if (response.data is! Map<String, dynamic>) {
      throw StateError('Invalid tenant registration response');
    }
    final data = response.data as Map<String, dynamic>;
    final saved = bank.copyWith(
      id: data['id'] as String? ?? bank.id,
      code: data['code'] as String? ?? bank.code.toUpperCase(),
      assignedSlug: data['slug'] as String? ?? slug,
      assignedSubdomain: data['subdomain'] as String? ?? bank.subdomain,
      tenantId: data['schemaName'] as String? ?? bank.tenantId,
      currency: data['primaryCurrency'] as String? ?? bank.currency,
    );
    if (!_banks.any((existing) => existing.id == saved.id)) {
      _banks.add(saved);
    }
    return saved;
  }

  @override
  Future<void> updateBankBranding({
    required String slug,
    required String primaryColor,
    required String accentColor,
    required String logoUrl,
  }) async {
    try {
      await dioClient.put(
        '${ApiEndpoints.tenants}/$slug/settings',
        data: {
          'primaryCurrency': 'COP',
          'maxTransactionAmount': '50000000.00',
          'feeType': 'FIXED',
          'feeValue': '2500.0000',
          'primaryColor': primaryColor,
          'accentColor': accentColor,
          'logoUrl': logoUrl,
        },
      );
    } catch (_) {}

    // Update in local cache as well
    for (int i = 0; i < _banks.length; i++) {
      if (_banks[i].slug == slug || _banks[i].id == slug) {
        _banks[i] = _banks[i].copyWith(
          primaryColorHex: primaryColor,
          accentColorHex: accentColor,
          logoKey: logoUrl,
        );
      }
    }
  }

  @override
  Future<List<BankAccountEntity>> getAccounts() async {
    try {
      final response = await dioClient.get(ApiEndpoints.myAccounts);
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        final realAccounts = list.map((item) {
          final m = item as Map<String, dynamic>;
          final curr = m['currency'] as String? ?? 'COP';
          final accNum = m['accountNumber'] as String? ?? '';
          final accType = curr == 'COP'
              ? 'Cuenta Débito'
              : (curr == 'USD'
                    ? 'Cuenta en Dólares (USD)'
                    : 'Cuenta en Euros (EUR)');
          final bal = double.tryParse(m['balance']?.toString() ?? '0') ?? 0.0;
          return BankAccountEntity(
            id: m['id'] as String? ?? accNum,
            accountNumber: accNum,
            accountType: accType,
            balance: bal,
            currency: curr,
            isActive: m['status'] == 'ACTIVE',
            tenantId: m['tenantId'] as String? ?? '',
          );
        }).toList();

        if (realAccounts.isNotEmpty) {
          for (final real in realAccounts) {
            final idx = _accounts.indexWhere(
              (a) => a.id == real.id || a.accountNumber == real.accountNumber,
            );
            if (idx != -1) {
              _accounts[idx] = real;
            } else {
              _accounts.add(real);
            }
          }
          _syncCardsWithAccounts();
          return List.unmodifiable(_accounts);
        }
      }
    } catch (_) {}
    return List.unmodifiable(_accounts);
  }

  @override
  Future<List<BankCardEntity>> getCards() async {
    _syncCardsWithAccounts();
    return List.unmodifiable(_cards);
  }

  @override
  Future<List<OperationRecordEntity>> getHistory() async {
    try {
      final slug = (AuthRemoteDataSourceImpl.activeTenantSlug != null &&
              AuthRemoteDataSourceImpl.activeTenantSlug!.isNotEmpty)
          ? (AuthRemoteDataSourceImpl.activeTenantSlug!.toLowerCase() == 'bos'
              ? 'banco-lombia'
              : AuthRemoteDataSourceImpl.activeTenantSlug!)
          : _resolveTenantSlug(_accounts.firstOrNull?.id);
      final response = await dioClient.get(ApiEndpoints.transactions(slug));
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list;
        if (response.data is Map<String, dynamic>) {
          list =
              (response.data as Map<String, dynamic>)['data']
                  as List<dynamic>? ??
              [];
        } else if (response.data is List<dynamic>) {
          list = response.data as List<dynamic>;
        } else {
          list = [];
        }
        final realHistory = list.map((item) {
          final m = item as Map<String, dynamic>;
          final typeStr = (m['type'] as String? ?? '').toUpperCase();
          final opType = typeStr == 'DEPOSIT'
              ? OperationType.deposit
              : (typeStr == 'WITHDRAWAL'
                    ? OperationType.withdrawal
                    : OperationType.internalTransfer);
          final amt =
              double.tryParse(m['originalAmount']?.toString() ?? '0') ?? 0.0;
          final curr = m['originalCurrency'] as String? ?? 'COP';
          final date =
              DateTime.tryParse(m['createdAt']?.toString() ?? '') ??
              DateTime.now();
          final srcAccId = m['sourceAccountId']?.toString();
          final dstAccId = m['destinationAccountId']?.toString();
          final isIncoming = opType == OperationType.internalTransfer &&
              (srcAccId == null || srcAccId.isEmpty || srcAccId == 'null');

          return OperationRecordEntity(
            id:
                m['id'] as String? ??
                'tx_${DateTime.now().millisecondsSinceEpoch}',
            type: opType,
            title: opType == OperationType.deposit
                ? 'Depósito bancario'
                : (opType == OperationType.withdrawal
                      ? 'Retiro de fondos'
                      : (isIncoming ? 'Transferencia recibida' : 'Transferencia realizada')),
            description: isIncoming
                ? 'Abono recibido en cuenta'
                : 'Operación registrada en ledger institucional',
            amount: amt,
            currency: curr,
            timestamp: date,
            originAccountId: srcAccId ?? '',
            destinationAccountId: dstAccId,
          );
        }).toList();

        if (realHistory.isNotEmpty) {
          _history.removeWhere((h) => realHistory.any((r) => r.id == h.id));
          _history.insertAll(0, realHistory);
          return List.unmodifiable(_history);
        }
      }
    } catch (_) {}
    return List.unmodifiable(_history);
  }

  @override
  Future<OperationRecordEntity> deposit({
    required String accountId,
    required double amount,
    String? concept,
  }) async {
    final idx = _accounts.indexWhere(
      (a) => a.id == accountId || a.accountNumber == accountId,
    );
    final targetAccount = idx != -1 ? _accounts[idx] : null;
    final accountNumber = targetAccount?.accountNumber ?? accountId;
    final slug = _resolveTenantSlug(accountId);

    try {
      final response = await dioClient.post(
        ApiEndpoints.deposits(slug),
        data: {
          'accountNumber': accountNumber,
          'amount': amount.toStringAsFixed(2),
        },
        options: Options(
          headers: {'Idempotency-Key': DioClient.generateIdempotencyKey()},
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newBal =
            double.tryParse(data['newBalance']?.toString() ?? '') ??
            ((targetAccount?.balance ?? 0) + amount);

        if (idx != -1 && targetAccount != null) {
          _accounts[idx] = targetAccount.copyWith(balance: newBal);
        }
        final cardIdx = _cards.indexWhere(
          (c) => c.cardNumber == accountNumber || c.accountId == accountId,
        );
        if (cardIdx != -1) {
          _cards[cardIdx] = _cards[cardIdx].copyWith(availableBalance: newBal);
        }
        _syncCardsWithAccounts();

        final record = OperationRecordEntity(
          id:
              data['transactionId'] as String? ??
              'dep_${DateTime.now().millisecondsSinceEpoch}',
          type: OperationType.deposit,
          title: 'Depósito a cuenta',
          description: concept ?? 'Abono de fondos exitoso',
          amount: amount,
          currency:
              data['currency'] as String? ?? targetAccount?.currency ?? 'COP',
          timestamp: DateTime.now(),
          originAccountId: accountId,
        );
        _history.insert(0, record);
        return record;
      }
    } catch (_) {}

    if (idx != -1) {
      final acc = _accounts[idx];
      _accounts[idx] = acc.copyWith(balance: acc.balance + amount);
      _syncCardsWithAccounts();

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
    final cardIdx = _cards.indexWhere((c) => c.id == card.id);
    if (cardIdx != -1) {
      final currentCard = _cards[cardIdx];
      if (amount <= 0) {
        throw ArgumentError('El monto debe ser estrictamente positivo.');
      }

      // Ejecutar depósito sobre la cuenta vinculada si existe
      if (currentCard.accountId.isNotEmpty || currentCard.cardNumber.isNotEmpty) {
        return deposit(
          accountId: currentCard.cardNumber.isNotEmpty
              ? currentCard.cardNumber
              : currentCard.accountId,
          amount: amount,
          concept: concept,
        );
      }

      _cards[cardIdx] = currentCard.copyWith(
        availableBalance: currentCard.availableBalance + amount,
      );

      final record = OperationRecordEntity(
        id: 'dep_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.deposit,
        title: 'Depósito Cuenta ${currentCard.bankName}',
        description:
            concept ??
            'Abono de fondos exitoso (${currentCard.maskedCardNumber})',
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
    final idx = _accounts.indexWhere(
      (a) => a.id == accountId || a.accountNumber == accountId,
    );
    final targetAccount = idx != -1 ? _accounts[idx] : null;
    final accountNumber = targetAccount?.accountNumber ?? accountId;
    final slug = _resolveTenantSlug(accountId);

    try {
      final response = await dioClient.post(
        ApiEndpoints.withdrawals(slug),
        data: {
          'accountNumber': accountNumber,
          'amount': amount.toStringAsFixed(2),
        },
        options: Options(
          headers: {'Idempotency-Key': DioClient.generateIdempotencyKey()},
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newBal =
            double.tryParse(data['newBalance']?.toString() ?? '') ??
            ((targetAccount?.balance ?? 0) - amount);

        if (idx != -1 && targetAccount != null) {
          _accounts[idx] = targetAccount.copyWith(balance: newBal);
        }
        final cardIdx = _cards.indexWhere(
          (c) => c.cardNumber == accountNumber || c.accountId == accountId,
        );
        if (cardIdx != -1) {
          _cards[cardIdx] = _cards[cardIdx].copyWith(availableBalance: newBal);
        }
        _syncCardsWithAccounts();

        final record = OperationRecordEntity(
          id:
              data['transactionId'] as String? ??
              'wit_${DateTime.now().millisecondsSinceEpoch}',
          type: OperationType.withdrawal,
          title: 'Retiro de efectivo',
          description: concept ?? 'Retiro de fondos exitoso',
          amount: amount,
          currency:
              data['currency'] as String? ?? targetAccount?.currency ?? 'COP',
          timestamp: DateTime.now(),
          originAccountId: accountId,
        );
        _history.insert(0, record);
        return record;
      }
    } catch (error) {
      if (DioClient.authToken != null && DioClient.authToken!.isNotEmpty) {
        throw Exception(UserFacingError.from(error));
      }
    }

    if (idx != -1) {
      final acc = _accounts[idx];
      if (acc.balance < amount) {
        throw Exception('Saldo insuficiente en la cuenta de origen.');
      }
      _accounts[idx] = acc.copyWith(balance: acc.balance - amount);
      _syncCardsWithAccounts();

      final record = OperationRecordEntity(
        id: 'wit_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.withdrawal,
        title: 'Retiro de efectivo',
        description: concept ?? 'Retiro de fondos exitoso',
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
    final cardIdx = _cards.indexWhere((c) => c.id == card.id);
    if (cardIdx == -1 && card.accountId.isNotEmpty) {
      return withdraw(
        accountId: card.accountId,
        amount: amount,
        concept: concept,
      );
    }
    if (cardIdx != -1) {
      final currentCard = _cards[cardIdx];
      if (amount <= 0) {
        throw ArgumentError('El monto debe ser estrictamente positivo.');
      }
      if (currentCard.availableBalance < amount) {
        throw ArgumentError('Saldo insuficiente en la tarjeta seleccionada.');
      }

      if (currentCard.accountId.isNotEmpty) {
        return withdraw(
          accountId: currentCard.accountId,
          amount: amount,
          concept: concept,
        );
      }

      _cards[cardIdx] = currentCard.copyWith(
        availableBalance: currentCard.availableBalance - amount,
      );

      final record = OperationRecordEntity(
        id: 'wdr_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.withdrawal,
        title: 'Retiro Tarjeta ${currentCard.bankName}',
        description:
            concept ?? 'Retiro de fondos (${currentCard.maskedCardNumber})',
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
    final originIdx = _accounts.indexWhere(
      (a) => a.id == originAccountId || a.accountNumber == originAccountId,
    );
    final destIdx = _accounts.indexWhere(
      (a) =>
          a.id == destinationAccountId ||
          a.accountNumber == destinationAccountId,
    );

    final originAcc = originIdx != -1 ? _accounts[originIdx] : null;
    final destAcc = destIdx != -1 ? _accounts[destIdx] : null;

    final srcNumber = originAcc?.accountNumber ?? originAccountId;
    final dstNumber = destAcc?.accountNumber ?? destinationAccountId;
    final slug = _resolveTenantSlug(originAccountId);

    try {
      final response = await dioClient.post(
        ApiEndpoints.transfers(slug),
        data: {
          'sourceAccountNumber': srcNumber,
          'destinationAccountNumber': dstNumber,
          'targetAmount': amount.toStringAsFixed(2),
          'sourceAmount': amount.toStringAsFixed(2),
        },
        options: Options(
          headers: {'Idempotency-Key': DioClient.generateIdempotencyKey()},
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newSrcBal = double.tryParse(
          data['sourceNewBalance']?.toString() ?? '',
        );

        if (originIdx != -1 && originAcc != null) {
          _accounts[originIdx] = originAcc.copyWith(
            balance: newSrcBal ?? (originAcc.balance - amount),
          );
        }
        double creditedAmount = amount;
        if (originAcc != null &&
            destAcc != null &&
            originAcc.currency != destAcc.currency) {
          final rate = StaticExchangeRate.getRate(
            originAcc.currency,
            destAcc.currency,
          );
          creditedAmount = amount * rate;
        }
        if (destIdx != -1 && destAcc != null) {
          _accounts[destIdx] = destAcc.copyWith(
            balance: destAcc.balance + creditedAmount,
          );
        }
        final origCardIdx = _cards.indexWhere(
          (c) => c.cardNumber == srcNumber || c.accountId == originAccountId,
        );
        if (origCardIdx != -1) {
          _cards[origCardIdx] = _cards[origCardIdx].copyWith(
            availableBalance:
                newSrcBal ?? (_cards[origCardIdx].availableBalance - amount),
          );
        }
        final destCardIdx = _cards.indexWhere(
          (c) =>
              c.cardNumber == dstNumber || c.accountId == destinationAccountId,
        );
        if (destCardIdx != -1) {
          _cards[destCardIdx] = _cards[destCardIdx].copyWith(
            availableBalance:
                _cards[destCardIdx].availableBalance + creditedAmount,
          );
        }
        _syncCardsWithAccounts();

        final record = OperationRecordEntity(
          id:
              data['transactionId'] as String? ??
              'tx_${DateTime.now().millisecondsSinceEpoch}',
          type: OperationType.internalTransfer,
          title: 'Transferencia realizada',
          description: concept ?? 'Transferencia enviada con éxito',
          amount: amount,
          currency: originAcc?.currency ?? 'COP',
          timestamp: DateTime.now(),
          originAccountId: originAccountId,
          destinationAccountId: destinationAccountId,
        );
        _history.insert(0, record);
        return record;
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        rethrow;
      }
    }

    if (originIdx != -1 && destIdx != -1) {
      final src = _accounts[originIdx];
      final dst = _accounts[destIdx];

      if (src.balance < amount) {
        throw Exception('Saldo insuficiente en la cuenta de origen.');
      }

      double creditedAmount = amount;
      if (src.currency != dst.currency) {
        final rate = StaticExchangeRate.getRate(src.currency, dst.currency);
        creditedAmount = amount * rate;
      }

      _accounts[originIdx] = src.copyWith(balance: src.balance - amount);
      _accounts[destIdx] = dst.copyWith(balance: dst.balance + creditedAmount);
      _syncCardsWithAccounts();

      final record = OperationRecordEntity(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.internalTransfer,
        title: 'Transferencia realizada',
        description: concept ?? 'Transferencia a ${dst.maskedAccountNumber}',
        amount: amount,
        currency: src.currency,
        timestamp: DateTime.now(),
        originAccountId: originAccountId,
        destinationAccountId: destinationAccountId,
      );
      _history.insert(0, record);
      return record;
    }
    throw Exception('Una de las cuentas no fue encontrada.');
  }

  @override
  Future<OperationRecordEntity> currencyExchange({
    required String originAccountId,
    required String destinationAccountId,
    required double amount,
    required double staticRate,
    String? concept,
  }) async {
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
    _syncCardsWithAccounts();

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
    final origIdx = _cards.indexWhere((c) => c.id == originCard.id);
    final destIdx = _cards.indexWhere((c) => c.id == destinationCard.id);

    if (origIdx == -1 || destIdx == -1) {
      throw Exception('Una o ambas tarjetas no existen.');
    }

    final orig = _cards[origIdx];
    final dest = _cards[destIdx];
    const fee = 0.0;
    final totalDebit = amount + fee;

    if (orig.availableBalance < totalDebit) {
      throw ArgumentError(
        'Saldo insuficiente en ${orig.bankName}. Disponible: ${orig.formattedBalance}. '
        'Requerido: \$${totalDebit.toStringAsFixed(2)} ${orig.currency}.',
      );
    }

    // Si ambas tarjetas tienen cuenta/tarjeta identificable, delegamos a internalTransfer
    final origAccId =
        orig.cardNumber.isNotEmpty ? orig.cardNumber : orig.accountId;
    final destAccId =
        dest.cardNumber.isNotEmpty ? dest.cardNumber : dest.accountId;

    if (origAccId.isNotEmpty && destAccId.isNotEmpty) {
      return internalTransfer(
        originAccountId: origAccId,
        destinationAccountId: destAccId,
        amount: amount,
        concept: concept,
      );
    }

    double creditedAmount = amount;
    if (orig.currency != dest.currency) {
      final rate = StaticExchangeRate.getRate(orig.currency, dest.currency);
      creditedAmount = amount * rate;
    }

    _cards[origIdx] = orig.copyWith(
      availableBalance: orig.availableBalance - totalDebit,
    );
    _cards[destIdx] = dest.copyWith(
      availableBalance: dest.availableBalance + creditedAmount,
    );

    final record = OperationRecordEntity(
      id: 'trf_${DateTime.now().millisecondsSinceEpoch}',
      type: orig.currency != dest.currency
          ? OperationType.currencyExchange
          : OperationType.internalTransfer,
      title: orig.currency != dest.currency
          ? 'Conversión multimoneda'
          : 'Transferencia interna',
      description:
          concept ??
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
