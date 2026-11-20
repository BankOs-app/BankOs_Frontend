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
  final String? sourceBankName;
  final String? destinationBankName;
  final String? sourceAccountNumber;
  final String? destinationAccountNumber;
  final String? sourceTenantId;
  final String? destinationTenantId;
  final bool isIncoming;
  final String? concept;
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
    this.sourceBankName,
    this.destinationBankName,
    this.sourceAccountNumber,
    this.destinationAccountNumber,
    this.sourceTenantId,
    this.destinationTenantId,
    this.isIncoming = false,
    this.concept,
    this.isSuccess = true,
  });

  bool get isCredit => type == OperationType.deposit || isIncoming;

  String get formattedAmount {
    final prefix = isCredit ? '+' : '-';
    final isDec = amount.truncateToDouble() != amount;
    final valStr =
        isDec ? amount.toStringAsFixed(2) : amount.toInt().toString();
    final parts = valStr.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    final symbol = currency == 'EUR' ? '€' : '\$';
    return '$prefix$symbol$formatted $currency';
  }
}
