import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/external_origin_account_entity.dart';
import '../../domain/entities/operation_record_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';

enum OperationsStatus { initial, loading, success, error }

class OperationsState {
  final OperationsStatus status;
  final List<BankAccountEntity> accounts;
  final List<RegisteredBankEntity> banks;
  final List<BankCardEntity> cards;
  final List<ExternalOriginAccountEntity> originAccounts;
  final List<OperationRecordEntity> history;
  final RegisteredBankEntity? activeBank;
  final String? errorMessage;
  final String? successMessage;

  const OperationsState({
    this.status = OperationsStatus.initial,
    this.accounts = const [],
    this.banks = const [
      RegisteredBankEntity(
        id: 'bank_bankos_global',
        name: 'Cuenta Global BankOs',
        code: 'BOS',
        tenantId: 'tenant_bankos_global',
        currency: 'USD',
        isGlobal: true,
      ),
      RegisteredBankEntity(
        id: 'bank_bancolombia',
        name: 'Bancolombia',
        code: '007',
        tenantId: 'tenant_bancolombia',
        currency: 'COP',
      ),
      RegisteredBankEntity(
        id: 'bank_davivienda',
        name: 'Davivienda',
        code: '051',
        tenantId: 'tenant_davivienda',
        currency: 'COP',
      ),
      RegisteredBankEntity(
        id: 'bank_chase',
        name: 'Chase Bank (EE.UU.)',
        code: '840',
        tenantId: 'tenant_chase',
        currency: 'USD',
      ),
      RegisteredBankEntity(
        id: 'bank_bogota',
        name: 'Banco de Bogotá',
        code: '001',
        tenantId: 'tenant_bogota',
        currency: 'COP',
      ),
      RegisteredBankEntity(
        id: 'bank_bbva',
        name: 'BBVA',
        code: '013',
        tenantId: 'tenant_bbva',
        currency: 'COP',
      ),
      RegisteredBankEntity(
        id: 'bank_santander',
        name: 'Banco Santander (España)',
        code: '049',
        tenantId: 'tenant_santander_eur',
        currency: 'EUR',
      ),
    ],
    this.cards = const [],
    this.originAccounts = const [
      ExternalOriginAccountEntity(
        id: 'orig_01',
        bankName: 'Bancolombia',
        accountType: 'Cuenta Débito',
        accountNumber: '1020305521',
        holderName: 'Carlos Gómez',
        documentNumber: '1020304050',
        currency: 'COP',
        balance: 24550.00,
      ),
      ExternalOriginAccountEntity(
        id: 'orig_02',
        bankName: 'Chase Bank (EE.UU.)',
        accountType: 'Cuenta Débito',
        accountNumber: '4030209840',
        holderName: 'Carlos Gómez',
        documentNumber: '1020304050',
        currency: 'USD',
        balance: 1250.00,
      ),
      ExternalOriginAccountEntity(
        id: 'orig_03',
        bankName: 'Davivienda',
        accountType: 'Cuenta Débito',
        accountNumber: '9920104410',
        holderName: 'Carlos Gómez',
        documentNumber: '1020304050',
        currency: 'COP',
        balance: 8320.00,
      ),
      ExternalOriginAccountEntity(
        id: 'orig_04',
        bankName: 'Banco Santander (España)',
        accountType: 'Cuenta Débito',
        accountNumber: '8830192031',
        holderName: 'Carlos Gómez',
        documentNumber: '1020304050',
        currency: 'EUR',
        balance: 1450.00,
      ),
    ],
    this.history = const [],
    this.activeBank,
    this.errorMessage,
    this.successMessage,
  });

  /// The active tenant / bank currently loaded in session
  RegisteredBankEntity get currentBank =>
      activeBank ??
      (banks.isNotEmpty
          ? banks.first
          : const RegisteredBankEntity(
              id: 'bank_bankos_global',
              name: 'Cuenta Global BankOs',
              code: 'BOS',
              tenantId: 'tenant_bankos_global',
              currency: 'USD',
              isGlobal: true,
            ));

  /// The global BankOs entity
  RegisteredBankEntity get globalBank => banks.firstWhere(
        (b) => b.isGlobal || b.id == 'bank_bankos_global',
        orElse: () => banks.first,
      );

  /// Whether current view is focused on the central BankOs global hub
  bool get isViewingGlobal =>
      currentBank.isGlobal || currentBank.id == 'bank_bankos_global';

  /// List of personal bank accounts added by the user
  List<RegisteredBankEntity> get personalBanks =>
      banks.where((b) => !b.isGlobal && b.id != 'bank_bankos_global').toList();

  /// Accounts isolated to the active tenant
  List<BankAccountEntity> get activeTenantAccounts {
    final tenantId = currentBank.tenantId;
    final list = accounts.where((a) => a.tenantId == tenantId).toList();
    if (list.isNotEmpty) return list;
    return accounts.where((a) => a.currency == currentBank.currency).toList();
  }

  /// Cards isolated to the active bank / tenant
  List<BankCardEntity> get activeTenantCards {
    final bankId = currentBank.id;
    return cards.where((c) => c.bankId == bankId).toList();
  }

  /// Primary card or account of the active tenant
  BankCardEntity? get primaryCard =>
      activeTenantCards.isNotEmpty ? activeTenantCards.first : null;

  BankAccountEntity? get primaryAccount =>
      activeTenantAccounts.isNotEmpty ? activeTenantAccounts.first : null;

  String get activeCurrency => currentBank.currency;

  double get activeBalance =>
      primaryCard?.availableBalance ?? primaryAccount?.balance ?? 0.0;

  String get formattedActiveBalance {
    final bal = activeBalance;
    final isDec = bal.truncateToDouble() != bal;
    final valStr = isDec ? bal.toStringAsFixed(2) : bal.toInt().toString();
    final parts = valStr.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    final symbol = activeCurrency == 'EUR' ? '€' : '\$';
    return '$symbol$formatted $activeCurrency';
  }

  /// Transaction history isolated strictly to the active tenant
  List<OperationRecordEntity> get activeTenantHistory {
    final tenantAccIds = activeTenantAccounts.map((a) => a.id).toSet();
    final tenantCardAccIds = activeTenantCards.map((c) => c.accountId).toSet();
    final allIds = {...tenantAccIds, ...tenantCardAccIds};

    final filtered = history.where((h) {
      return allIds.contains(h.originAccountId) ||
          allIds.contains(h.destinationAccountId);
    }).toList();

    if (filtered.isNotEmpty) return filtered;

    // Fallback: filter by currency matching current bank
    return history.where((h) => h.currency == currentBank.currency).toList();
  }

  List<BankCardEntity> getCardsForBank(String bankId) {
    return cards.where((c) => c.bankId == bankId).toList();
  }

  OperationsState copyWith({
    OperationsStatus? status,
    List<BankAccountEntity>? accounts,
    List<RegisteredBankEntity>? banks,
    List<BankCardEntity>? cards,
    List<ExternalOriginAccountEntity>? originAccounts,
    List<OperationRecordEntity>? history,
    RegisteredBankEntity? activeBank,
    String? errorMessage,
    String? successMessage,
  }) {
    return OperationsState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      banks: banks ?? this.banks,
      cards: cards ?? this.cards,
      originAccounts: originAccounts ?? this.originAccounts,
      history: history ?? this.history,
      activeBank: activeBank ?? this.activeBank,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}
