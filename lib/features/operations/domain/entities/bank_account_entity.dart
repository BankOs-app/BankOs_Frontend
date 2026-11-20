class BankAccountEntity {
  final String id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String currency;
  final bool isActive;
  final String tenantId;

  const BankAccountEntity({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.isActive,
    this.tenantId = 'tenant_bankos_01',
  });

  String get maskedAccountNumber => accountNumber;

  String get formattedBalance {
    final isDec = balance.truncateToDouble() != balance;
    final valStr = isDec ? balance.toStringAsFixed(2) : balance.toInt().toString();
    final parts = valStr.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final formatted = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    return '\$$formatted $currency';
  }

  BankAccountEntity copyWith({
    String? id,
    String? accountNumber,
    String? accountType,
    double? balance,
    String? currency,
    bool? isActive,
    String? tenantId,
  }) {
    return BankAccountEntity(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      tenantId: tenantId ?? this.tenantId,
    );
  }
}
