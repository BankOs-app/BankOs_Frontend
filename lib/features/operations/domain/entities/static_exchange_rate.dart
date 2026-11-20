class StaticExchangeRate {
  final String fromCurrency;
  final String toCurrency;
  final double rate;

  const StaticExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
  });

  /// Static table configured by tenant
  static const List<StaticExchangeRate> tenantRates = [
    StaticExchangeRate(fromCurrency: 'USD', toCurrency: 'COP', rate: 4150.0),
    StaticExchangeRate(fromCurrency: 'COP', toCurrency: 'USD', rate: 0.000241),
    StaticExchangeRate(fromCurrency: 'EUR', toCurrency: 'USD', rate: 1.08),
    StaticExchangeRate(fromCurrency: 'USD', toCurrency: 'EUR', rate: 0.926),
    StaticExchangeRate(fromCurrency: 'EUR', toCurrency: 'COP', rate: 4482.0),
    StaticExchangeRate(fromCurrency: 'COP', toCurrency: 'EUR', rate: 0.000223),
  ];

  static double getRate(String from, String to) {
    if (from == to) return 1.0;
    for (final r in tenantRates) {
      if (r.fromCurrency == from && r.toCurrency == to) {
        return r.rate;
      }
    }
    // Fallback default
    return 1.0;
  }
}
