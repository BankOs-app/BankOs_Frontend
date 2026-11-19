enum BankCardType { debit, credit }

class BankCardEntity {
  final String id;
  final String bankId;
  final String bankName;
  final String cardNumber;
  final String cardHolder;
  final BankCardType cardType;
  final double availableBalance;
  final String currency;
  final bool isActive;
  final String accountId;

  const BankCardEntity({
    required this.id,
    required this.bankId,
    required this.bankName,
    required this.cardNumber,
    required this.cardHolder,
    required this.cardType,
    required this.availableBalance,
    this.currency = 'COP',
    this.isActive = true,
    required this.accountId,
  });

  String get maskedCardNumber => '•••• $cardNumber';

  String get currencySymbol {
    if (currency == 'EUR') return '€';
    return '\$';
  }

  String get formattedBalance {
    final isDec = availableBalance.truncateToDouble() != availableBalance;
    final valStr = isDec
        ? availableBalance.toStringAsFixed(2)
        : availableBalance.toInt().toString();
    final parts = valStr.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return '$currencySymbol$formatted $currency';
  }

  String get cardTypeLabel {
    switch (cardType) {
      case BankCardType.debit:
        return 'Cuenta Débito';
      case BankCardType.credit:
        return 'Cuenta Crédito';
    }
  }

  BankCardEntity copyWith({
    String? id,
    String? bankId,
    String? bankName,
    String? cardNumber,
    String? cardHolder,
    BankCardType? cardType,
    double? availableBalance,
    String? currency,
    bool? isActive,
    String? accountId,
  }) {
    return BankCardEntity(
      id: id ?? this.id,
      bankId: bankId ?? this.bankId,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      cardType: cardType ?? this.cardType,
      availableBalance: availableBalance ?? this.availableBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      accountId: accountId ?? this.accountId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankCardEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
