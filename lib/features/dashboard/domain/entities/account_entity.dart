class AccountEntity {
  final String id;
  final String accountNumber;
  final String accountType;
  final double balance;
  final String currency;
  final bool isActive;

  const AccountEntity({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.currency,
    required this.isActive,
  });

  String get maskedAccountNumber => '•••• $accountNumber';

  String get formattedBalance {
    final intBalance = balance.toInt();
    final formatted = intBalance.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '\$$formatted $currency';
  }
}
