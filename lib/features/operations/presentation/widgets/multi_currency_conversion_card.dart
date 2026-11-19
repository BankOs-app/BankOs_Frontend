import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../domain/entities/static_exchange_rate.dart';

/// TABLERO DE CONVERSIÓN EN TIEMPO REAL
/// - Muestra la conversión dinámica únicamente entre las divisas de origen y destino cuando difieren.
/// - Si la divisa de origen y destino son iguales (ej. COP -> COP), se oculta suavemente.
/// - Totalmente integrado a la paleta oficial de BankOs (AppColors.softBackground, primaryNavy, textSecondary).
/// - Integra animaciones suaves con `package:animations` (SharedAxisTransition vertical + AnimatedSize).
/// - Adaptado tanto para Depósitos como para Retiros.
class MultiCurrencyConversionCard extends ConsumerWidget {
  final String originCurrency;
  final String destinationCurrency;
  final double amount;
  final bool isWithdrawal;
  final double commission;
  final String? commissionCurrency;

  const MultiCurrencyConversionCard({
    super.key,
    required this.originCurrency,
    required this.destinationCurrency,
    required this.amount,
    this.isWithdrawal = false,
    this.commission = 0.0,
    this.commissionCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orig = originCurrency.toUpperCase().trim();
    final dest = destinationCurrency.toUpperCase().trim();
    final bool hasConversion =
        orig.isNotEmpty && dest.isNotEmpty && orig != dest;

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: hasConversion
          ? Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: KeyedSubtree(
                  key: ValueKey('conv_${orig}_${dest}_$isWithdrawal'),
                  child: _buildCard(context, ref, orig, dest),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildCard(
      BuildContext context, WidgetRef ref, String orig, String dest) {
    final lang = ref.watch(localeNotifierProvider);

    final double rate;
    final double fromAmount;
    final double toAmount;
    final String fromCurr;
    final String toCurr;
    final String fromLabel;
    final String toLabel;
    final String fromSub;
    final String toSub;

    if (!isWithdrawal) {
      // Depósito: Se envía `amount` en `orig` y se acredita en `dest`.
      fromCurr = orig;
      toCurr = dest;
      rate = StaticExchangeRate.getRate(fromCurr, toCurr);
      fromAmount = amount;
      toAmount = amount > 0 ? (amount * rate) : 0.0;
      fromLabel = Tr.amountToDebit(lang);
      fromSub = Tr.originAccountSub(lang);
      toLabel = Tr.amountToCredit(lang);
      toSub = Tr.destAccountSub(lang);
    } else {
      // Retiro: El usuario retira `amount` en `dest` (divisa seleccionada)
      // y se debita de su tarjeta (`orig`).
      fromCurr = dest;
      toCurr = orig;
      rate = StaticExchangeRate.getRate(fromCurr, toCurr);
      fromAmount = amount;
      toAmount = amount > 0 ? (amount * rate) : 0.0;
      fromLabel = Tr.amountToWithdraw(lang);
      fromSub = Tr.withdrawCashSub(lang);
      toLabel = Tr.cardDebit(lang);
      toSub = Tr.originAccountSub(lang);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Título integrado y limpio en la paleta de BankOs
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: const Icon(Icons.currency_exchange_rounded,
                    color: AppColors.primaryNavy, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Tr.conversionTitleForPair(lang, fromCurr, toCurr),
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Cajas de conversión: Ambas con AppColors.softBackground idénticas a los inputs del formulario
          Row(
            children: [
              // Caja Moneda de Origen / Solicitada
              Expanded(
                child: _buildCurrencyBox(
                  currency: fromCurr,
                  label: fromLabel,
                  amount: fromAmount,
                  subtitle: fromSub,
                ),
              ),
              // Conector central sutil
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ),
              // Caja Moneda de Destino / Débito
              Expanded(
                child: _buildCurrencyBox(
                  currency: toCurr,
                  label: toLabel,
                  amount: toAmount,
                  subtitle: toSub,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Tasa oficial aplicada en los tonos neutros de BankOs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.softBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    Tr.systemRateApplied(
                        lang, fromCurr, _formatRate(rate), toCurr),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  Tr.noHiddenSpread(lang),
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBox({
    required String currency,
    required String label,
    required double amount,
    required String subtitle,
  }) {
    final symbol = currency == 'EUR' ? '€' : '\$';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  currency,
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Animación suave de transición en el número al teclear
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Text(
              '$symbol${_formatCurrency(amount)} $currency',
              key: ValueKey('${currency}_${amount.toStringAsFixed(2)}'),
              style: const TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
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

  String _formatRate(double rate) {
    if (rate >= 100) {
      return rate.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    } else if (rate >= 1) {
      return rate.toStringAsFixed(2);
    } else {
      return rate.toStringAsFixed(6);
    }
  }
}
