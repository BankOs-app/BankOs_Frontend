import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_locale_provider.dart';
import '../../domain/entities/static_exchange_rate.dart';

/// TABLERO DE CONVERSIÓN EN TIEMPO REAL A DÓLARES Y EUROS
/// - Muestra la conversión automática a USD y EUR en cada depósito y retiro.
/// - Si la divisa de origen y destino difieren, muestra el monto exacto a recibir en destino.
/// - Diseño limpio y visualmente integrado con la paleta de BankOs.
/// - Reactivo a AppLanguage (Español / Inglés).
class MultiCurrencyConversionCard extends ConsumerWidget {
  final String originCurrency;
  final String destinationCurrency;
  final double amount;
  final double commission;
  final String? commissionCurrency;

  const MultiCurrencyConversionCard({
    super.key,
    required this.originCurrency,
    required this.destinationCurrency,
    required this.amount,
    this.commission = 0.0,
    this.commissionCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeNotifierProvider);
    final orig = originCurrency.toUpperCase();
    final dest = destinationCurrency.toUpperCase();

    // Cálculo a Dólares y Euros según divisa de origen
    final double usdAmount;
    final double eurAmount;

    if (orig == 'USD') {
      usdAmount = amount;
      eurAmount = amount * StaticExchangeRate.getRate('USD', 'EUR');
    } else if (orig == 'EUR') {
      eurAmount = amount;
      usdAmount = amount * StaticExchangeRate.getRate('EUR', 'USD');
    } else {
      // Por defecto COP
      usdAmount = amount * StaticExchangeRate.getRate('COP', 'USD');
      eurAmount = amount * StaticExchangeRate.getRate('COP', 'EUR');
    }

    final destRate = StaticExchangeRate.getRate(orig, dest);
    final convertedDestAmount = amount > 0 ? (amount * destRate) : 0.0;
    final isCrossCurrency = orig != dest;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Conversión en Dólares y Euros
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.currency_exchange_rounded,
                    color: Color(0xFF2563EB), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Tr.conversionTitle(lang),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tarjetas de conversión en Dólares ($ USD) y Euros (€ EUR)
          Row(
            children: [
              // Cuadro Dólares (USD)
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Tr.inDollars(lang),
                            style: const TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'USD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_formatCurrency(usdAmount)} USD',
                        style: const TextStyle(
                          color: Color(0xFF166534),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '1 USD = \$4,150 COP',
                        style: TextStyle(color: Color(0xFF65A30D), fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Cuadro Euros (EUR)
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE9D5FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Tr.inEuros(lang),
                            style: const TextStyle(
                              color: Color(0xFF7E22CE),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9333EA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'EUR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€${_formatCurrency(eurAmount)} EUR',
                        style: const TextStyle(
                          color: Color(0xFF6B21A8),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '1 EUR = \$4,482 COP',
                        style: TextStyle(color: Color(0xFF9333EA), fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Si la operación es multidivisa (ej. COP -> USD o viceversa)
          if (isCrossCurrency) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded,
                      color: Color(0xFF2563EB), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Tr.estimatedDestination(lang, dest),
                          style: const TextStyle(
                            color: Color(0xFF1E40AF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '+\$${_formatCurrency(convertedDestAmount)} $dest',
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '1 $orig = $destRate $dest',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Tasas de referencia configuradas en el tenant
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  Tr.tenantRatesLabel(lang),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                Tr.noHiddenSpread(lang),
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final isDec = value.truncateToDouble() != value;
    final valStr = isDec ? value.toStringAsFixed(2) : value.toInt().toString();
    final parts = valStr.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
  }
}
