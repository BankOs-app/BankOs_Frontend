import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.id,
    required super.accountNumber,
    required super.accountType,
    required super.balance,
    required super.currency,
    required super.isActive,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String? ?? '',
      accountNumber: json['accountNumber'] as String? ?? '4829',
      accountType: json['accountType'] as String? ?? 'Checking Account',
      balance: (json['balance'] as num?)?.toDouble() ?? 12450000.0,
      currency: json['currency'] as String? ?? 'COP',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
      'currency': currency,
      'isActive': isActive,
    };
  }
}
