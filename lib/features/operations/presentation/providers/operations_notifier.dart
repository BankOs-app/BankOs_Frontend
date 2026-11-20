import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/external_origin_account_entity.dart';
import '../../domain/entities/operation_record_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
import '../../domain/entities/static_exchange_rate.dart';
import '../../domain/usecases/currency_exchange_usecase.dart';
import '../../domain/usecases/deposit_usecase.dart';
import '../../domain/usecases/internal_transfer_usecase.dart';
import '../../domain/usecases/withdraw_usecase.dart';
import 'operations_providers.dart';
import 'operations_state.dart';

class OperationsNotifier extends Notifier<OperationsState> {
  @override
  OperationsState build() {
    Future.microtask(loadInitialData);
    return const OperationsState(status: OperationsStatus.initial);
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final repository = ref.read(operationsRepositoryProvider);
      final accounts = await repository.getAccounts();
      final banks = await repository.getBanks();
      final cards = await repository.getCards();
      final history = await repository.getHistory();
      final currentActive = state.activeBank ?? (banks.isNotEmpty ? banks.first : null);
      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: accounts,
        banks: banks,
        cards: cards,
        history: history,
        activeBank: currentActive,
      );
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void switchActiveBank(RegisteredBankEntity bank) {
    AuthRemoteDataSourceImpl.activeTenantSlug = bank.code;
    state = state.copyWith(activeBank: bank);
  }

  void switchActiveBankByEmail(String email) {
    final lower = email.toLowerCase();
    RegisteredBankEntity? target;
    if (lower.contains('bancolombia') || lower.contains('lombia')) {
      target = state.banks
          .where((b) =>
              b.code.contains('lombia') ||
              b.name.toLowerCase().contains('bancolombia'))
          .firstOrNull;
    } else if (lower.contains('bogota')) {
      target = state.banks
          .where((b) =>
              b.code.contains('bogota') ||
              b.name.toLowerCase().contains('bogot'))
          .firstOrNull;
    } else if (lower.contains('santander')) {
      target = state.banks
          .where((b) =>
              b.code.contains('santander') ||
              b.name.toLowerCase().contains('santander'))
          .firstOrNull;
    } else if (lower.contains('nu')) {
      target = state.banks
          .where((b) =>
              b.code.contains('nu') ||
              b.name.toLowerCase().contains('nu'))
          .firstOrNull;
    } else if (lower.contains('bankos')) {
      target = state.banks
          .where((b) => b.isGlobal || b.id == 'bank_bankos_global')
          .firstOrNull;
    }
    if (target != null) {
      state = state.copyWith(activeBank: target);
    }
  }

  void registerNewTenantBank(RegisteredBankEntity newBank) {
    final updatedBanks = [...state.banks, newBank];
    state = state.copyWith(banks: updatedBanks);
  }

  Future<bool> updateBankBranding({
    required String bankId,
    required String primaryColorHex,
    required String accentColorHex,
    required String logoKey,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final repository = ref.read(operationsRepositoryProvider);
      final bank = state.banks.firstWhere((b) => b.id == bankId);

      await repository.updateBankBranding(
        slug: bank.code.isNotEmpty ? bank.code : bank.id,
        primaryColor: primaryColorHex,
        accentColor: accentColorHex,
        logoUrl: logoKey,
      );

      final updatedBanks = state.banks.map((b) {
        if (b.id == bankId) {
          return b.copyWith(
            primaryColorHex: primaryColorHex,
            accentColorHex: accentColorHex,
            logoKey: logoKey,
          );
        }
        return b;
      }).toList();

      RegisteredBankEntity? updatedActive = state.activeBank;
      if (updatedActive?.id == bankId || (updatedActive == null && updatedBanks.isNotEmpty && updatedBanks.first.id == bankId)) {
        updatedActive = (updatedActive ?? updatedBanks.first).copyWith(
          primaryColorHex: primaryColorHex,
          accentColorHex: accentColorHex,
          logoKey: logoKey,
        );
      }

      state = state.copyWith(
        status: OperationsStatus.success,
        banks: updatedBanks,
        activeBank: updatedActive,
        successMessage: 'Identidad visual de ${bank.name} actualizada exitosamente.',
      );
      return true;
    } catch (_) {
      // Contingencia local si el endpoint devuelve error no fatal
      final updatedBanks = state.banks.map((b) {
        if (b.id == bankId) {
          return b.copyWith(
            primaryColorHex: primaryColorHex,
            accentColorHex: accentColorHex,
            logoKey: logoKey,
          );
        }
        return b;
      }).toList();

      RegisteredBankEntity? updatedActive = state.activeBank;
      if (updatedActive?.id == bankId) {
        updatedActive = updatedActive?.copyWith(
          primaryColorHex: primaryColorHex,
          accentColorHex: accentColorHex,
          logoKey: logoKey,
        );
      }

      state = state.copyWith(
        status: OperationsStatus.success,
        banks: updatedBanks,
        activeBank: updatedActive,
        successMessage: 'Identidad visual actualizada localmente.',
      );
      return true;
    }
  }

  Future<bool> executeDeposit({
    required BankAccountEntity account,
    required double amount,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final useCase = ref.read(depositUseCaseProvider);
      final record = await useCase(
        DepositParams(account: account, amount: amount, concept: concept),
      );

      final repository = ref.read(operationsRepositoryProvider);
      final updatedAccounts = await repository.getAccounts();
      final updatedHistory = await repository.getHistory();

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        history: updatedHistory,
        successMessage:
            '¡Depósito de \$${record.amount} ${record.currency} realizado con éxito!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> executeDepositToCard({
    required RegisteredBankEntity bank,
    required BankCardEntity card,
    required double amount,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final repository = ref.read(operationsRepositoryProvider);
      final record = await repository.depositToCard(
        card: card,
        amount: amount,
        concept: concept,
      );

      final updatedAccounts = await repository.getAccounts();
      final updatedCards = await repository.getCards();
      final updatedHistory = await repository.getHistory();

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        cards: updatedCards,
        history: updatedHistory,
        successMessage:
            '¡Depósito de \$${record.amount} ${record.currency} abonado con éxito a tu ${card.cardTypeLabel} (${card.maskedCardNumber}) en ${bank.name}!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> executeDepositFromOrigin({
    required String originBankName,
    required String originAccountNumber,
    required String originAccountType,
    required String originCurrency,
    required RegisteredBankEntity destBank,
    required BankCardEntity destCard,
    required double amount,
    String? concept,
    bool saveNewOriginAccount = false,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final repository = ref.read(operationsRepositoryProvider);

      // Conversión multimoneda con tasas estáticas si difieren las monedas
      double creditedAmount = amount;
      String operationDesc = concept ?? 'Depósito desde $originBankName ($originAccountNumber)';

      if (originCurrency != destCard.currency) {
        final rate = StaticExchangeRate.getRate(originCurrency, destCard.currency);
        creditedAmount = amount * rate;
        operationDesc = 'Conversión $originCurrency -> ${destCard.currency} (Tasa: $rate)';
      }

      final record = await repository.depositToCard(
        card: destCard,
        amount: creditedAmount,
        concept: operationDesc,
      );

      final updatedAccounts = await repository.getAccounts();
      final updatedCards = await repository.getCards();
      final updatedHistory = await repository.getHistory();

      var currentOrigins =
          List<ExternalOriginAccountEntity>.from(state.originAccounts);
      if (saveNewOriginAccount) {
        final alreadyExists = currentOrigins.any(
          (o) =>
              o.bankName == originBankName &&
              o.accountNumber == originAccountNumber,
        );
        if (!alreadyExists) {
          currentOrigins.add(
            ExternalOriginAccountEntity(
              id: 'orig_${DateTime.now().millisecondsSinceEpoch}',
              bankName: originBankName,
              accountType: originAccountType,
              accountNumber: originAccountNumber,
              holderName: 'Carlos Gómez',
              currency: originCurrency,
            ),
          );
        }
      }

      final msg = originCurrency != destCard.currency
          ? '¡Depósito multimoneda procesado! \$$amount $originCurrency convertidos a \$${record.amount.toStringAsFixed(2)} ${destCard.currency} y acreditados a tu ${destCard.cardTypeLabel} en ${destBank.name}.'
          : '¡Depósito de \$${record.amount} ${record.currency} realizado con éxito desde $originBankName a tu ${destCard.cardTypeLabel} (${destCard.maskedCardNumber}) en ${destBank.name}!';

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        cards: updatedCards,
        originAccounts: currentOrigins,
        history: updatedHistory,
        successMessage: msg,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> executeWithdraw({
    required BankAccountEntity account,
    required double amount,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final useCase = ref.read(withdrawUseCaseProvider);
      final record = await useCase(
        WithdrawParams(account: account, amount: amount, concept: concept),
      );

      final repository = ref.read(operationsRepositoryProvider);
      final updatedAccounts = await repository.getAccounts();
      final updatedHistory = await repository.getHistory();

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        history: updatedHistory,
        successMessage:
            '¡Retiro de \$${record.amount} ${record.currency} procesado correctamente!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> executeWithdrawFromCard({
    required RegisteredBankEntity bank,
    required BankCardEntity card,
    required double amount,
    String withdrawCurrency = 'COP',
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final repository = ref.read(operationsRepositoryProvider);

      // Si la moneda en que se retira difiere de la moneda de la tarjeta
      double debitAmount = amount;
      String desc = concept ?? '${card.cardTypeLabel} (${card.maskedCardNumber})';

      if (withdrawCurrency != card.currency) {
        final rate = StaticExchangeRate.getRate(withdrawCurrency, card.currency);
        debitAmount = amount * rate;
        desc = 'Retiro en $withdrawCurrency con conversión desde ${card.currency}';
      }

      final record = await repository.withdrawFromCard(
        card: card,
        amount: debitAmount,
        concept: desc,
      );

      final updatedAccounts = await repository.getAccounts();
      final updatedCards = await repository.getCards();
      final updatedHistory = await repository.getHistory();

      final msg = withdrawCurrency != card.currency
          ? '¡Retiro procesado! Se debitaron \$${debitAmount.toStringAsFixed(2)} ${card.currency} de tu tarjeta para entregarte \$${amount.toStringAsFixed(2)} $withdrawCurrency.'
          : '¡Retiro de \$${record.amount} ${record.currency} procesado exitosamente desde ${card.cardTypeLabel} (${card.maskedCardNumber}) en ${bank.name}!';

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        cards: updatedCards,
        history: updatedHistory,
        successMessage: msg,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> executeInternalTransfer({
    required BankAccountEntity originAccount,
    required BankAccountEntity destinationAccount,
    required double amount,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final useCase = ref.read(internalTransferUseCaseProvider);
      final record = await useCase(
        InternalTransferParams(
          originAccount: originAccount,
          destinationAccount: destinationAccount,
          amount: amount,
          concept: concept,
        ),
      );

      final repository = ref.read(operationsRepositoryProvider);
      final updatedAccounts = await repository.getAccounts();
      final updatedHistory = await repository.getHistory();

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        history: updatedHistory,
        successMessage:
            '¡Transferencia de \$${record.amount} ${record.currency} realizada con éxito (Comisión: \$${record.fee})!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> executeCurrencyExchange({
    required BankAccountEntity originAccount,
    required BankAccountEntity destinationAccount,
    required double amount,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final useCase = ref.read(currencyExchangeUseCaseProvider);
      final record = await useCase(
        CurrencyExchangeParams(
          originAccount: originAccount,
          destinationAccount: destinationAccount,
          amount: amount,
          concept: concept,
        ),
      );

      final repository = ref.read(operationsRepositoryProvider);
      final updatedAccounts = await repository.getAccounts();
      final updatedHistory = await repository.getHistory();

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        history: updatedHistory,
        successMessage:
            '¡Conversión completada! \$${record.amount} ${originAccount.currency} transferidos con éxito.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  Future<bool> executeCardTransfer({
    required RegisteredBankEntity originBank,
    required BankCardEntity originCard,
    required RegisteredBankEntity destinationBank,
    required BankCardEntity destinationCard,
    required double amount,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      final repository = ref.read(operationsRepositoryProvider);
      final record = await repository.transferBetweenCards(
        originCard: originCard,
        destinationCard: destinationCard,
        amount: amount,
        concept: concept,
      );

      final updatedAccounts = await repository.getAccounts();
      final updatedCards = await repository.getCards();
      final updatedHistory = await repository.getHistory();

      final isMultiCurrency = originCard.currency != destinationCard.currency;
      final msg = isMultiCurrency
          ? '¡Transferencia multimoneda exitosa! Se debitaron \$${amount.toStringAsFixed(2)} ${originCard.currency} (Comisión: \$${record.fee}) y se acreditaron a tu cuenta en ${destinationBank.name}.'
          : '¡Transferencia de \$${amount.toStringAsFixed(2)} ${originCard.currency} realizada con éxito a ${destinationBank.name} (${destinationCard.maskedCardNumber})!';

      state = state.copyWith(
        status: OperationsStatus.success,
        accounts: updatedAccounts,
        cards: updatedCards,
        history: updatedHistory,
        successMessage: msg,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  void enrollOriginAccount(ExternalOriginAccountEntity account) {
    final current = List<ExternalOriginAccountEntity>.from(state.originAccounts);
    if (!current.any((a) =>
        a.accountNumber == account.accountNumber &&
        a.bankName == account.bankName)) {
      current.add(account);
      state = state.copyWith(originAccounts: current);
    }
  }

  /// Registra una nueva cuenta bancaria personal externa (ej. Bancolombia, Santander, etc.)
  void registerPersonalAccount({
    required String bankName,
    required BankCardType cardType,
    required String accountNumber,
    required String currency,
    required double initialBalance,
    required String holderName,
  }) {
    // 1. Obtener o crear entidad del banco
    final bankId =
        'bank_${bankName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';
    final existingBankIdx = state.banks.indexWhere(
      (b) =>
          b.id == bankId ||
          b.name.trim().toLowerCase() == bankName.trim().toLowerCase(),
    );
    RegisteredBankEntity bank;
    final updatedBanks = List<RegisteredBankEntity>.from(state.banks);

    if (existingBankIdx != -1) {
      bank = updatedBanks[existingBankIdx];
    } else {
      bank = RegisteredBankEntity(
        id: bankId,
        name: bankName,
        code: '999',
        tenantId: 'tenant_$bankId',
        currency: currency,
        isGlobal: false,
      );
      updatedBanks.add(bank);
    }

    // 2. Crear tarjeta / producto financiero para este banco
    final cardId = 'card_${DateTime.now().millisecondsSinceEpoch}';
    final accId = 'acc_${DateTime.now().millisecondsSinceEpoch}';
    final newCard = BankCardEntity(
      id: cardId,
      bankId: bank.id,
      bankName: bank.name,
      cardNumber: accountNumber.length > 4
          ? accountNumber.substring(accountNumber.length - 4)
          : accountNumber,
      cardHolder: holderName,
      cardType: cardType,
      availableBalance: initialBalance,
      currency: currency,
      accountId: accId,
    );

    final updatedCards = List<BankCardEntity>.from(state.cards)..add(newCard);

    // 3. Crear cuenta de origen externa registrada
    final newOrigin = ExternalOriginAccountEntity(
      id: 'orig_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bank.name,
      accountType:
          cardType == BankCardType.debit ? 'Cuenta Débito' : 'Cuenta Crédito',
      accountNumber: accountNumber,
      holderName: holderName,
      currency: currency,
      balance: initialBalance,
    );

    final updatedOrigins =
        List<ExternalOriginAccountEntity>.from(state.originAccounts);
    if (!updatedOrigins.any(
        (o) => o.accountNumber == accountNumber && o.bankName == bank.name)) {
      updatedOrigins.add(newOrigin);
    }

    // 4. Crear cuenta subyacente
    final newAccount = BankAccountEntity(
      id: accId,
      accountNumber: newCard.cardNumber,
      accountType:
          cardType == BankCardType.debit ? 'Cuenta Débito' : 'Cuenta Crédito',
      balance: initialBalance,
      currency: currency,
      isActive: true,
      tenantId: bank.tenantId,
    );
    final updatedAccounts = List<BankAccountEntity>.from(state.accounts)
      ..add(newAccount);

    state = state.copyWith(
      banks: updatedBanks,
      cards: updatedCards,
      originAccounts: updatedOrigins,
      accounts: updatedAccounts,
      successMessage: '¡Cuenta en ${bank.name} registrada exitosamente!',
    );
  }

  /// Consignación / Depósito directo desde una cuenta personal externa hacia la Cuenta Global BankOs
  Future<bool> consignToBankOs({
    required ExternalOriginAccountEntity originAccount,
    required double originAmount,
    required BankCardEntity destinationCard,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      if (originAmount <= 0) {
        throw Exception('El monto a consignar debe ser mayor a 0.');
      }
      if (originAccount.balance < originAmount) {
        throw Exception(
          'Saldo insuficiente en ${originAccount.bankName}. Saldo disponible: ${originAccount.formattedBalance}',
        );
      }

      // Cálculo de conversión si difieren las monedas
      double creditedAmount = originAmount;
      double rate = 1.0;
      if (originAccount.currency != destinationCard.currency) {
        rate = StaticExchangeRate.getRate(
            originAccount.currency, destinationCard.currency);
        creditedAmount = originAmount * rate;
      }

      // Debitar cuenta de origen en originAccounts
      final updatedOrigins = state.originAccounts.map((o) {
        if (o.id == originAccount.id ||
            (o.bankName == originAccount.bankName &&
                o.accountNumber == originAccount.accountNumber)) {
          return o.copyWith(balance: o.balance - originAmount);
        }
        return o;
      }).toList();

      // Actualizar tarjetas (acreditar destino y debitar tarjeta de origen si existe)
      final updatedCards = state.cards.map((c) {
        if (c.id == destinationCard.id) {
          return c.copyWith(
              availableBalance: c.availableBalance + creditedAmount);
        }
        if (c.bankName == originAccount.bankName &&
            c.currency == originAccount.currency) {
          return c.copyWith(
              availableBalance:
                  (c.availableBalance - originAmount).clamp(0, double.infinity));
        }
        return c;
      }).toList();

      // Actualizar cuentas
      final updatedAccounts = state.accounts.map((a) {
        if (a.id == destinationCard.accountId) {
          return a.copyWith(balance: a.balance + creditedAmount);
        }
        return a;
      }).toList();

      final record = OperationRecordEntity(
        id: 'cng_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.deposit,
        title: 'Consignación a Cuenta Global BankOs',
        description: concept ??
            'Consignación desde ${originAccount.bankName} (${originAccount.currency}) - Tasa: $rate',
        amount: creditedAmount,
        currency: destinationCard.currency,
        fee: 0.0,
        timestamp: DateTime.now(),
        originAccountId: originAccount.id,
        destinationAccountId: destinationCard.accountId,
      );

      final updatedHistory = List<OperationRecordEntity>.from(state.history)
        ..insert(0, record);

      final symb = destinationCard.currencySymbol;
      state = state.copyWith(
        status: OperationsStatus.success,
        originAccounts: updatedOrigins,
        cards: updatedCards,
        accounts: updatedAccounts,
        history: updatedHistory,
        successMessage:
            '¡Consignación exitosa! Se debitaron ${originAccount.currencySymbol}${originAmount.toStringAsFixed(2)} ${originAccount.currency} y se acreditaron $symb${creditedAmount.toStringAsFixed(2)} ${destinationCard.currency} en tu Cuenta Global BankOs.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }

  /// Retiro desde la Cuenta Global BankOs hacia una cuenta personal externa registrada
  Future<bool> withdrawFromBankOsToPersonal({
    required BankCardEntity originBankOsCard,
    required ExternalOriginAccountEntity destinationAccount,
    required double withdrawAmountUsd,
    String? concept,
  }) async {
    state = state.copyWith(status: OperationsStatus.loading);
    try {
      if (withdrawAmountUsd <= 0) {
        throw Exception('El monto a retirar debe ser mayor a 0.');
      }
      if (originBankOsCard.availableBalance < withdrawAmountUsd) {
        throw Exception(
          'Saldo insuficiente en BankOs Global (${originBankOsCard.formattedBalance}).',
        );
      }

      // Conversión de USD a la moneda de la cuenta de destino
      double creditedAmount = withdrawAmountUsd;
      double rate = 1.0;
      if (originBankOsCard.currency != destinationAccount.currency) {
        rate = StaticExchangeRate.getRate(
            originBankOsCard.currency, destinationAccount.currency);
        creditedAmount = withdrawAmountUsd * rate;
      }

      // Debitar tarjeta BankOs
      final updatedCards = state.cards.map((c) {
        if (c.id == originBankOsCard.id) {
          return c.copyWith(
              availableBalance: c.availableBalance - withdrawAmountUsd);
        }
        if (c.bankName == destinationAccount.bankName &&
            c.currency == destinationAccount.currency) {
          return c.copyWith(
              availableBalance: c.availableBalance + creditedAmount);
        }
        return c;
      }).toList();

      // Acreditar cuenta de destino en originAccounts
      final updatedOrigins = state.originAccounts.map((o) {
        if (o.id == destinationAccount.id ||
            (o.bankName == destinationAccount.bankName &&
                o.accountNumber == destinationAccount.accountNumber)) {
          return o.copyWith(balance: o.balance + creditedAmount);
        }
        return o;
      }).toList();

      // Actualizar cuentas bancarias
      final updatedAccounts = state.accounts.map((a) {
        if (a.id == originBankOsCard.accountId) {
          return a.copyWith(balance: a.balance - withdrawAmountUsd);
        }
        return a;
      }).toList();

      final record = OperationRecordEntity(
        id: 'wdr_${DateTime.now().millisecondsSinceEpoch}',
        type: OperationType.withdrawal,
        title: 'Retiro hacia ${destinationAccount.bankName}',
        description: concept ??
            'Retiro desde BankOs Global hacia cuenta ${destinationAccount.accountType} (${destinationAccount.currency})',
        amount: withdrawAmountUsd,
        currency: originBankOsCard.currency,
        fee: 0.0,
        timestamp: DateTime.now(),
        originAccountId: originBankOsCard.accountId,
        destinationAccountId: destinationAccount.id,
      );

      final updatedHistory = List<OperationRecordEntity>.from(state.history)
        ..insert(0, record);

      final destSymb = destinationAccount.currencySymbol;
      state = state.copyWith(
        status: OperationsStatus.success,
        originAccounts: updatedOrigins,
        cards: updatedCards,
        accounts: updatedAccounts,
        history: updatedHistory,
        successMessage:
            '¡Retiro exitoso! Se debitaron \$${withdrawAmountUsd.toStringAsFixed(2)} USD de BankOs y se acreditaron $destSymb${creditedAmount.toStringAsFixed(2)} ${destinationAccount.currency} en tu cuenta ${destinationAccount.bankName}.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: OperationsStatus.error,
        errorMessage: e
            .toString()
            .replaceFirst('Exception: ', '')
            .replaceFirst('ArgumentError: ', ''),
      );
      return false;
    }
  }
}
