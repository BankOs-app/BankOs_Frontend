import '../../domain/entities/account_entity.dart';
import '../../domain/entities/transaction_entity.dart';

enum DashboardStatus { initial, loading, success, error }

class DashboardState {
  final DashboardStatus status;
  final AccountEntity? account;
  final List<TransactionEntity> transactions;
  final bool hideBalance;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    this.account,
    this.transactions = const [],
    this.hideBalance = false,
    this.errorMessage,
  });

  DashboardState copyWith({
    DashboardStatus? status,
    AccountEntity? account,
    List<TransactionEntity>? transactions,
    bool? hideBalance,
    String? errorMessage,
  }) {
    return DashboardState(
      status: status ?? this.status,
      account: account ?? this.account,
      transactions: transactions ?? this.transactions,
      hideBalance: hideBalance ?? this.hideBalance,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
