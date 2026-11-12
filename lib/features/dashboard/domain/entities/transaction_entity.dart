class TransactionEntity {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final String currency;
  final bool isPositive;
  final String category;
  final DateTime date;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.currency,
    required this.isPositive,
    required this.category,
    required this.date,
  });

  String get formattedAmount {
    final intAmount = amount.toInt();
    final formatted = intAmount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    final sign = isPositive ? '+' : '-';
    return '$sign\$$formatted $currency';
  }
}
