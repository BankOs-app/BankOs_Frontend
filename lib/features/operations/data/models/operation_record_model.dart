import '../../domain/entities/operation_record_entity.dart';

class OperationRecordModel extends OperationRecordEntity {
  const OperationRecordModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.amount,
    required super.currency,
    super.convertedAmount,
    super.destinationCurrency,
    super.fee = 0.0,
    required super.timestamp,
    required super.originAccountId,
    super.destinationAccountId,
    super.isSuccess = true,
  });

  factory OperationRecordModel.fromJson(Map<String, dynamic> json) {
    return OperationRecordModel(
      id: json['id'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'COP',
      convertedAmount: (json['convertedAmount'] as num?)?.toDouble(),
      destinationCurrency: json['destinationCurrency'] as String?,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      originAccountId: json['originAccountId'] as String? ?? '',
      destinationAccountId: json['destinationAccountId'] as String?,
      isSuccess: json['isSuccess'] as bool? ?? true,
    );
  }

  static OperationType _parseType(String? typeStr) {
    switch (typeStr) {
      case 'deposit':
        return OperationType.deposit;
      case 'withdrawal':
        return OperationType.withdrawal;
      case 'currencyExchange':
        return OperationType.currencyExchange;
      case 'internalTransfer':
      default:
        return OperationType.internalTransfer;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'amount': amount,
      'currency': currency,
      'convertedAmount': convertedAmount,
      'destinationCurrency': destinationCurrency,
      'fee': fee,
      'timestamp': timestamp.toIso8601String(),
      'originAccountId': originAccountId,
      'destinationAccountId': destinationAccountId,
      'isSuccess': isSuccess,
    };
  }
}
