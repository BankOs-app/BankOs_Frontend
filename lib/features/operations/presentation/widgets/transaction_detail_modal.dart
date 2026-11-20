import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../domain/entities/operation_record_entity.dart';

class TransactionDetailModal extends StatelessWidget {
  final OperationRecordEntity record;
  final AppLanguage lang;

  const TransactionDetailModal({
    super.key,
    required this.record,
    required this.lang,
  });

  static Future<void> show(
    BuildContext context,
    OperationRecordEntity record,
    AppLanguage lang,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(
        record: record,
        lang: lang,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final monthsEs = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    final monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final months = lang == AppLanguage.es ? monthsEs : monthsEn;
    final m = months[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} $m ${dt.year}, $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = record.isCredit;
    final Color badgeColor = isCredit
        ? const Color(0xFF10B981)
        : const Color(0xFF2563EB);
    final Color amountColor = isCredit
        ? const Color(0xFF16A34A)
        : const Color(0xFF0F172A);

    final String originBank = record.sourceBankName ??
        (record.type == OperationType.deposit ? 'Taquilla / PSE' : 'BankOS');
    final String destBank = record.destinationBankName ??
        (record.type == OperationType.withdrawal ? 'Cajero Automático' : 'BankOS');

    final String originAccount = (record.sourceAccountNumber != null &&
            record.sourceAccountNumber!.isNotEmpty)
        ? record.sourceAccountNumber!
        : (record.originAccountId.isNotEmpty ? record.originAccountId : 'No especificada');

    final String destAccount = (record.destinationAccountNumber != null &&
            record.destinationAccountNumber!.isNotEmpty)
        ? record.destinationAccountNumber!
        : (record.destinationAccountId != null && record.destinationAccountId!.isNotEmpty
            ? record.destinationAccountId!
            : 'No especificada');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),

            // Circle icon
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isCredit
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: isCredit
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              record.title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    lang == AppLanguage.es ? 'Transacción Exitosa' : 'Successful Transaction',
                    style: const TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount
            Text(
              record.formattedAmount,
              style: TextStyle(
                color: amountColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 20),

            // Detailed info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildRow(
                    label: lang == AppLanguage.es ? 'Banco Origen' : 'Origin Bank',
                    value: originBank,
                    icon: Icons.account_balance_rounded,
                  ),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildRow(
                    label: lang == AppLanguage.es ? 'Cuenta Emisora' : 'Source Account',
                    value: originAccount,
                    icon: Icons.credit_card_rounded,
                  ),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildRow(
                    label: lang == AppLanguage.es ? 'Banco Destino' : 'Destination Bank',
                    value: destBank,
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildRow(
                    label: lang == AppLanguage.es ? 'Cuenta Receptora' : 'Recipient Account',
                    value: destAccount,
                    icon: Icons.numbers_rounded,
                  ),
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildRow(
                    label: lang == AppLanguage.es ? 'Fecha y Hora' : 'Date & Time',
                    value: _formatDate(record.timestamp),
                    icon: Icons.schedule_rounded,
                  ),
                  if (record.description.isNotEmpty &&
                      !record.description.contains('ledger institucional')) ...[
                    const Divider(height: 18, color: Color(0xFFE2E8F0)),
                    _buildRow(
                      label: lang == AppLanguage.es ? 'Concepto' : 'Concept',
                      value: record.description,
                      icon: Icons.notes_rounded,
                    ),
                  ],
                  const Divider(height: 18, color: Color(0xFFE2E8F0)),
                  _buildRow(
                    label: lang == AppLanguage.es ? 'ID de Referencia' : 'Reference ID',
                    value: record.id.length > 16
                        ? '${record.id.substring(0, 8)}...${record.id.substring(record.id.length - 6)}'
                        : record.id,
                    icon: Icons.tag_rounded,
                    trailing: IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: record.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              lang == AppLanguage.es
                                  ? 'ID copiado al portapapeles'
                                  : 'ID copied to clipboard',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Close button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  lang == AppLanguage.es ? 'Cerrar Comprobante' : 'Close Receipt',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required IconData icon,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          trailing,
        ],
      ],
    );
  }
}
