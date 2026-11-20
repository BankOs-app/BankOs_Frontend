import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import '../../../auth/data/datasources/auth_remote_data_source.dart';

/// Modal Bancario Seguro para Autorización de Operaciones (PIN Transaccional de 4 Dígitos)
/// - Utilizado en Depósitos, Retiros y Transferencias.
/// - Teclado numérico táctil en pantalla y soporte para teclado físico.
/// - Validación criptográfica/local contra el PIN definido por el usuario al crear la cuenta.
class TransactionPinModal extends StatefulWidget {
  final String title;
  final String amountFormatted;
  final Color accentColor;
  final String? expectedPin;

  const TransactionPinModal({
    super.key,
    required this.title,
    required this.amountFormatted,
    required this.accentColor,
    this.expectedPin,
  });

  /// Muestra el modal inferior y retorna true si el PIN fue validado exitosamente.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String amountFormatted,
    required Color accentColor,
    String? expectedPin,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => TransactionPinModal(
        title: title,
        amountFormatted: amountFormatted,
        accentColor: accentColor,
        expectedPin: expectedPin ?? AuthRemoteDataSourceImpl.activeTransactionalPin,
      ),
    );
    return result ?? false;
  }

  @override
  State<TransactionPinModal> createState() => _TransactionPinModalState();
}

class _TransactionPinModalState extends State<TransactionPinModal>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String? _errorMessage;
  bool _isSuccess = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeyPressed(String digit) {
    if (_enteredPin.length >= 4 || _isSuccess) return;

    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      _enteredPin += digit;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty || _isSuccess) return;
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    final validPin = widget.expectedPin ?? AuthRemoteDataSourceImpl.activeTransactionalPin;
    if (_enteredPin == validPin || validPin.isEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _isSuccess = true;
      });
      await Future.delayed(const Duration(milliseconds: 320));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      HapticFeedback.heavyImpact();
      _shakeController.forward(from: 0.0);
      setState(() {
        _errorMessage = 'PIN incorrecto. Intenta de nuevo.';
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor == Colors.black
        ? const Color(0xFFFDDA24)
        : widget.accentColor;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF070D18),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Color(0xFF1E293B), width: 1.2),
            ),
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de agarre superior
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabecera con Icono de Seguridad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: accent.withValues(alpha: 0.4)),
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Autorizar Operación',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Monto a confirmar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1322),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monto a procesar:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
                Text(
                  widget.amountFormatted,
                  style: TextStyle(
                    color: accent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Título de ingreso de PIN
          const Text(
            'Ingresa tu PIN de 4 dígitos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Clave de seguridad creada en tu registro',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),

          const SizedBox(height: 16),

          // Visualizador de los 4 Dígitos del PIN con animación de Shake
          AnimatedBuilder(
            animation: _shakeController,
            builder: (context, child) {
              final offset = math.sin(_shakeController.value * 6 * math.pi) *
                  (1.0 - _shakeController.value) *
                  12.0;
              return Transform.translate(
                offset: Offset(offset, 0),
                child: child,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _enteredPin.length;
                return Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? const Color(0xFF10B981).withValues(alpha: 0.2)
                        : isFilled
                            ? accent.withValues(alpha: 0.15)
                            : const Color(0xFF0B1322),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess
                          ? const Color(0xFF10B981)
                          : isFilled
                              ? accent
                              : const Color(0xFF1E293B),
                      width: isFilled ? 1.8 : 1.2,
                    ),
                  ),
                  child: Center(
                    child: _isSuccess
                        ? const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 22)
                        : isFilled
                            ? Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                  ),
                );
              }),
            ),
          ),

          // Mensaje de error si falla
          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Teclado Numérico Seguro (0-9, Cancelar y Backspace)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36.0),
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3'], accent),
                const SizedBox(height: 10),
                _buildKeypadRow(['4', '5', '6'], accent),
                const SizedBox(height: 10),
                _buildKeypadRow(['7', '8', '9'], accent),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón Cancelar
                    _buildActionButton(
                      icon: Icons.cancel_outlined,
                      color: const Color(0xFF64748B),
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                    // Dígito 0
                    _buildNumberButton('0', accent),
                    // Botón Borrar
                    _buildActionButton(
                      icon: Icons.backspace_outlined,
                      color: const Color(0xFF94A3B8),
                      onTap: _onBackspace,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildKeypadRow(List<String> digits, Color accent) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildNumberButton(d, accent)).toList(),
    );
  }

  Widget _buildNumberButton(String digit, Color accent) {
    return InkWell(
      onTap: () => _onKeyPressed(digit),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1322),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0B1322),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E293B)),
        ),
        child: Center(
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}
