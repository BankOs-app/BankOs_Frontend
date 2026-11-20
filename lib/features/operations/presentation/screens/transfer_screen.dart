import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/bank_card_entity.dart';
import '../../domain/entities/registered_bank_entity.dart';
import '../../domain/entities/static_exchange_rate.dart';
import '../providers/operations_providers.dart';
import '../providers/operations_state.dart';
import '../widgets/transaction_pin_modal.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();

  RegisteredBankEntity? _selectedOriginBank;
  BankCardEntity? _selectedOriginCard;

  RegisteredBankEntity? _selectedDestBank;
  BankCardEntity? _selectedDestCard;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _proceedToPreview() {
    final origBank = _selectedOriginBank;
    final origCard = _selectedOriginCard;
    final destBank = _selectedDestBank;
    final destCard = _selectedDestCard;

    if (origBank == null || origCard == null) {
      _showSnackBar('Selecciona el banco y cuenta de origen.');
      return;
    }

    if (destBank == null || destCard == null) {
      _showSnackBar('Selecciona el banco y cuenta de destino.');
      return;
    }

    if (origCard.id == destCard.id) {
      _showSnackBar('La cuenta de origen y destino no pueden ser la misma.');
      return;
    }

    if (!origCard.isActive) {
      _showSnackBar('La cuenta de origen no se encuentra activa.');
      return;
    }

    if (!destCard.isActive) {
      _showSnackBar('La cuenta de destino no se encuentra activa.');
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackBar('Ingresa un monto numérico válido mayor a 0.');
      return;
    }

    if (origCard.availableBalance < amount) {
      _showSnackBar(
        'Saldo insuficiente en ${origBank.name}. Disponible: ${origCard.formattedBalance}.',
      );
      return;
    }

    _showPreviewModal(
      origBank: origBank,
      origCard: origCard,
      destBank: destBank,
      destCard: destCard,
      amount: amount,
    );
  }

  void _showPreviewModal({
    required RegisteredBankEntity origBank,
    required BankCardEntity origCard,
    required RegisteredBankEntity destBank,
    required BankCardEntity destCard,
    required double amount,
  }) {
    final isMultiCurrency = origCard.currency != destCard.currency;
    final double exchangeRate;
    final double recipientAmount;

    if (isMultiCurrency) {
      exchangeRate = StaticExchangeRate.getRate(origCard.currency, destCard.currency);
      recipientAmount = amount * exchangeRate;
    } else {
      exchangeRate = 1.0;
      recipientAmount = amount;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (modalContext) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.currency_exchange_rounded,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Detalle y Divisa a Recibir',
                            style: TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Tarjeta destacada de monto que recibirá el destinatario
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF0F172A),
                          origBank.primaryColor == Colors.black
                              ? const Color(0xFF1E293B)
                              : origBank.primaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'El destinatario recibirá exactamente:',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${destCard.currency} \$${recipientAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isMultiCurrency) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              origCard.currency == 'COP' && destCard.currency == 'USD'
                                  ? 'Tasa aplicada: 1 USD ≈ \$4,150 COP (1 COP = 0.000241 USD)'
                                  : (origCard.currency == 'USD' && destCard.currency == 'COP'
                                      ? 'Tasa aplicada: 1 USD ≈ \$4,150 COP'
                                      : 'Tasa de cambio: 1 ${origCard.currency} = ${exchangeRate.toStringAsFixed(4)} ${destCard.currency}'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Desglose de Cuentas
                  _buildPreviewRow(
                    label: 'Cuenta de origen:',
                    value: '${origBank.name} • No. ${origCard.cardNumber}',
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                    label: 'Cuenta destino:',
                    value: '${destBank.name} • No. ${destCard.cardNumber}',
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                    label: 'Monto debitado:',
                    value: '${origCard.currency} \$${amount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildPreviewRow(
                    label: 'Comisión de transferencia:',
                    value: 'Gratis (\$0.00)',
                    valueColor: const Color(0xFF16A34A),
                  ),

                  const SizedBox(height: 24),

                  // Botón para autorizar y enviar
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        _executeFinalTransfer(
                          origBank: origBank,
                          origCard: origCard,
                          destBank: destBank,
                          destCard: destCard,
                          amount: amount,
                          recipientAmount: recipientAmount,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Confirmar y Enviar Fondos',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreviewRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.softBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.primaryNavy,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeFinalTransfer({
    required RegisteredBankEntity origBank,
    required BankCardEntity origCard,
    required RegisteredBankEntity destBank,
    required BankCardEntity destCard,
    required double amount,
    required double recipientAmount,
  }) async {
    final brandAccent = origBank.accentColor;
    final authorized = await TransactionPinModal.show(
      context,
      title: 'Transferir a ${destBank.name}',
      amountFormatted: '${origCard.currency} \$${amount.toStringAsFixed(2)}',
      accentColor: brandAccent,
    );
    if (!authorized || !mounted) return;

    final success = await ref
        .read(operationsNotifierProvider.notifier)
        .executeCardTransfer(
          originBank: origBank,
          originCard: origCard,
          destinationBank: destBank,
          destinationCard: destCard,
          amount: amount,
          concept: _conceptController.text.trim().isNotEmpty
              ? _conceptController.text.trim()
              : 'Traspaso a ${destBank.name} (No. ${destCard.cardNumber})',
        );

    if (mounted) {
      final state = ref.read(operationsNotifierProvider);
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    color: Color(0xFF10B981), size: 28),
                SizedBox(width: 8),
                Text(
                  'Transferencia Exitosa',
                  style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  origCard.currency != destCard.currency
                      ? 'Se debitaron \$${amount.toStringAsFixed(2)} ${origCard.currency} de tu cuenta en ${origBank.name} y se acreditaron \$${recipientAmount.toStringAsFixed(2)} ${destCard.currency} en la cuenta de ${destBank.name} (No. ${destCard.cardNumber}).'
                      : 'Se han transferido \$${amount.toStringAsFixed(2)} ${origCard.currency} desde ${origBank.name} hacia ${destBank.name} (No. ${destCard.cardNumber}).',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
        _amountController.clear();
        _conceptController.clear();
      } else {
        _showSnackBar(state.errorMessage ??
            'Ocurrió un error al procesar la transferencia.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(operationsNotifierProvider);
    final banks = operationsState.banks;

    if (_selectedOriginBank == null && banks.isNotEmpty) {
      _selectedOriginBank = operationsState.currentBank;
    }

    final availableOriginCards = _selectedOriginBank != null
        ? operationsState.getCardsForBank(_selectedOriginBank!.id)
        : <BankCardEntity>[];

    if (_selectedDestBank == null && banks.isNotEmpty) {
      final otherBanks =
          banks.where((b) => b.id != _selectedOriginBank?.id).toList();
      _selectedDestBank =
          otherBanks.isNotEmpty ? otherBanks.first : banks.first;
    }

    final availableDestCards = _selectedDestBank != null
        ? operationsState.getCardsForBank(_selectedDestBank!.id)
        : <BankCardEntity>[];

    final isLoading = operationsState.status == OperationsStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primaryNavy, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'Transferencia de Fondos',
          style: TextStyle(
            color: AppColors.primaryNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CUENTA DE ORIGEN
              const Text(
                '1. Cuenta de origen (De dónde saldrán los fondos):',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Selector Banco Origen
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RegisteredBankEntity>(
                    value: _selectedOriginBank,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primaryNavy),
                    items: banks.map((bank) {
                      return DropdownMenuItem<RegisteredBankEntity>(
                        value: bank,
                        child: Text(
                          '${bank.name} (${bank.currency})',
                          style: const TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (bank) {
                      setState(() {
                        _selectedOriginBank = bank;
                        _selectedOriginCard = null;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Selector Tarjeta/Cuenta Origen con número de cuenta real
              if (availableOriginCards.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BankCardEntity>(
                      value: _selectedOriginCard,
                      hint: const Text(
                        'Selecciona número de cuenta de origen...',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primaryNavy),
                      items: availableOriginCards.map((card) {
                        return DropdownMenuItem<BankCardEntity>(
                          value: card,
                          child: Text(
                            '${card.cardTypeLabel} - No. ${card.cardNumber} (${card.formattedBalance})',
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (card) {
                        setState(() {
                          _selectedOriginCard = card;
                        });
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              // 2. CUENTA DESTINO
              const Text(
                '2. Cuenta destino (A dónde se enviarán los fondos):',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Selector Banco Destino
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RegisteredBankEntity>(
                    value: _selectedDestBank,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primaryNavy),
                    items: banks.map((bank) {
                      return DropdownMenuItem<RegisteredBankEntity>(
                        value: bank,
                        child: Text(
                          '${bank.name} (${bank.currency})',
                          style: const TextStyle(
                            color: AppColors.primaryNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (bank) {
                      setState(() {
                        _selectedDestBank = bank;
                        _selectedDestCard = null;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Selector Tarjeta/Cuenta Destino con número real
              if (availableDestCards.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.softBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BankCardEntity>(
                      value: _selectedDestCard,
                      hint: const Text(
                        'Selecciona número de cuenta de destino...',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                      ),
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: AppColors.primaryNavy),
                      items: availableDestCards.map((card) {
                        return DropdownMenuItem<BankCardEntity>(
                          value: card,
                          child: Text(
                            '${card.cardTypeLabel} - No. ${card.cardNumber} (${card.formattedBalance})',
                            style: const TextStyle(
                              color: AppColors.primaryNavy,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (card) {
                        setState(() {
                          _selectedDestCard = card;
                        });
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              // 3. MONTO A TRANSFERIR
              const Text(
                '3. Monto a transferir:',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    color: AppColors.primaryNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.attach_money_rounded,
                        color: AppColors.brandBlue, size: 20),
                    suffixText: _selectedOriginCard?.currency ?? 'COP',
                    suffixStyle: const TextStyle(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    hintText: '0.00',
                    hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Concepto (Opcional)
              const Text(
                'Concepto (opcional):',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.softBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _conceptController,
                  style: const TextStyle(
                      color: AppColors.primaryNavy, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Pago de servicios o envío a familiares',
                    hintStyle:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Botón Revisar y Continuar (Abre la pestaña de cotización y divisa)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _proceedToPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continuar y Revisar Divisa',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
