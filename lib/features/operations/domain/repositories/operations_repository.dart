import '../entities/bank_account_entity.dart';
import '../entities/bank_card_entity.dart';
import '../entities/operation_record_entity.dart';
import '../entities/registered_bank_entity.dart';

abstract class OperationsRepository {
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
