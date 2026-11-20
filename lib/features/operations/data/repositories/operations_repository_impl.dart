import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/operation_record_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
import '../../domain/repositories/operations_repository.dart';
import '../datasources/operations_remote_data_source.dart';

class OperationsRepositoryImpl implements OperationsRepository {
  final OperationsRemoteDataSource remoteDataSource;

  OperationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BankAccountEntity>> getAccounts() {
    return remoteDataSource.getAccounts();
  }

  @override
  Future<List<RegisteredBankEntity>> getBanks() {
    return remoteDataSource.getBanks();
  }

  @override
  Future<RegisteredBankEntity> registerTenant(RegisteredBankEntity bank) {
    return remoteDataSource.registerTenant(bank);
  }

  @override
  Future<List<BankCardEntity>> getCards() {
    return remoteDataSource.getCards();
  }

  @override
  Future<List<OperationRecordEntity>> getHistory() {
    return remoteDataSource.getHistory();
  }

  @override
  Future<OperationRecordEntity> deposit({
    required String accountId,
    required double amount,
    String? concept,
  }) {
    return remoteDataSource.deposit(
      accountId: accountId,
      amount: amount,
      concept: concept,
    );
  }

  @override
  Future<OperationRecordEntity> depositToCard({
    required BankCardEntity card,
    required double amount,
    String? concept,
  }) {
    return remoteDataSource.depositToCard(
      card: card,
      amount: amount,
      concept: concept,
    );
  }

  @override
  Future<OperationRecordEntity> withdraw({
    required String accountId,
    required double amount,
    String? concept,
  }) {
    return remoteDataSource.withdraw(
      accountId: accountId,
      amount: amount,
      concept: concept,
    );
  }

  @override
  Future<OperationRecordEntity> withdrawFromCard({
    required BankCardEntity card,
    required double amount,
    String? concept,
  }) {
    return remoteDataSource.withdrawFromCard(
      card: card,
      amount: amount,
      concept: concept,
    );
  }

  @override
  Future<OperationRecordEntity> internalTransfer({
    required String originAccountId,
    required String destinationAccountId,
    required double amount,
    String? concept,
  }) {
    return remoteDataSource.internalTransfer(
      originAccountId: originAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      concept: concept,
    );
  }

  @override
  Future<OperationRecordEntity> currencyExchange({
    required String originAccountId,
    required String destinationAccountId,
    required double amount,
    required double staticRate,
    String? concept,
  }) {
    return remoteDataSource.currencyExchange(
      originAccountId: originAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      staticRate: staticRate,
      concept: concept,
    );
  }

  @override
  Future<OperationRecordEntity> transferBetweenCards({
    required BankCardEntity originCard,
    required BankCardEntity destinationCard,
    required double amount,
    String? concept,
  }) {
    return remoteDataSource.transferBetweenCards(
      originCard: originCard,
      destinationCard: destinationCard,
      amount: amount,
      concept: concept,
    );
  }

  @override
  Future<void> updateBankBranding({
    required String slug,
    required String primaryColor,
    required String accentColor,
    required String logoUrl,
  }) {
    return remoteDataSource.updateBankBranding(
      slug: slug,
      primaryColor: primaryColor,
      accentColor: accentColor,
      logoUrl: logoUrl,
    );
  }
}
