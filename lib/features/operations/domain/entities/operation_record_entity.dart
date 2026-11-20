enum OperationType {
  deposit,
  withdrawal,
  internalTransfer,
  currencyExchange,
}

class OperationRecordEntity {
  final String id;
  final OperationType type;
  final String title;
  final String description;
  final double amount;
  final String currency;
  final double? convertedAmount;
  final String? destinationCurrency;
  final double fee;
  final DateTime timestamp;
  final String originAccountId;
  final String? destinationAccountId;
  final bool isSuccess;

  const OperationRecordEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    required this.currency,
    this.convertedAmount,
    this.destinationCurrency,
    this.fee = 0.0,
    required this.timestamp,
    required this.originAccountId,
    this.destinationAccountId,
    this.isSuccess = true,
  });

  String get formattedAmount {
    final prefix = type == OperationType.deposit ? '+' : '-';
    final isDec = amount.truncateToDouble() != amount;
    final valStr = isDec ? amount.toStringAsFixed(2) : amount.toInt().toString();
    return '$prefix\$$valStr $currency';
  }
}
