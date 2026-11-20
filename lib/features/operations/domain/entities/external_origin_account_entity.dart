class ExternalOriginAccountEntity {
  final String id;
  final String bankName;
  final String accountType; // 'Cuenta Débito' | 'Cuenta Crédito'
  final String accountNumber;
  final String holderName;
  final String documentNumber;
  final String currency;
  final double balance;

  const ExternalOriginAccountEntity({
    required this.id,
    required this.bankName,
    required this.accountType,
    required this.accountNumber,
    required this.holderName,
    this.documentNumber = '',
    this.currency = 'COP',
    this.balance = 0.0,
  });

  String get maskedAccountNumber => accountNumber;

  String get currencySymbol {
    if (currency == 'EUR') return '€';
    return '\$';
  }

  String get formattedBalance {
    final isDec = balance.truncateToDouble() != balance;
    final valStr =
        isDec ? balance.toStringAsFixed(2) : balance.toInt().toString();
    final parts = valStr.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return '$currencySymbol$formatted $currency';
  }

  ExternalOriginAccountEntity copyWith({
    String? id,
    String? bankName,
    String? accountType,
    String? accountNumber,
    String? holderName,
    String? documentNumber,
    String? currency,
    double? balance,
  }) {
    return ExternalOriginAccountEntity(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountType: accountType ?? this.accountType,
      accountNumber: accountNumber ?? this.accountNumber,
      holderName: holderName ?? this.holderName,
      documentNumber: documentNumber ?? this.documentNumber,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExternalOriginAccountEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
