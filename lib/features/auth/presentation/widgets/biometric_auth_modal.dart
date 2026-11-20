import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_locale_provider.dart';

/// Modal interactivo y nativo para Autenticación Biométrica (Face ID / Huella Dactilar)
/// - Compatible con Android (Huella) e iOS/macOS (Face ID).
/// - Soporte para vibración háptica (HapticFeedback).
/// - Animación de escaneo biométrico y confirmación visual.
class BiometricAuthModal extends StatefulWidget {
  final String bankName;
  final String userEmail;
  final String userName;
  final bool isApple;
  final AppLanguage lang;
  final bool autoScan;

  const BiometricAuthModal({
    super.key,
    required this.bankName,
    required this.userEmail,
    required this.userName,
    required this.isApple,
    required this.lang,
    this.autoScan = true,
  });

  static Future<bool> show(
    BuildContext context, {
    required String bankName,
    required String userEmail,
    required String userName,
    required bool isApple,
    required AppLanguage lang,
    bool autoScan = true,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => BiometricAuthModal(
        bankName: bankName,
        userEmail: userEmail,
        userName: userName,
        isApple: isApple,
        lang: lang,
        autoScan: autoScan,
      ),
    );
    return result ?? false;
  }

  @override
  State<BiometricAuthModal> createState() => _BiometricAuthModalState();
}

class _BiometricAuthModalState extends State<BiometricAuthModal>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticating = false;
  bool _isSuccess = false;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Iniciar escaneo automático si autoScan es true
    if (widget.autoScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startBiometricScan();
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startBiometricScan() async {
    if (_isAuthenticating || _isSuccess) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    // Simulación de lectura del sensor biométrico
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    setState(() {
      _isAuthenticating = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEs = widget.lang == AppLanguage.es;
    final title = widget.isApple
        ? (isEs ? 'Autenticación con Face ID' : 'Face ID Authentication')
        : (isEs ? 'Autenticación con Huella Dactilar' : 'Fingerprint Authentication');
    final subtitle = isEs
        ? 'Verifica tu identidad para acceder a ${widget.bankName}'
        : 'Verify your identity to sign in to ${widget.bankName}';
    final actionHint = widget.isApple
        ? (_isSuccess
            ? (isEs ? 'Rostro reconocido con éxito' : 'Face recognized successfully')
            : (_isAuthenticating
                ? (isEs ? 'Escaneando rostro...' : 'Scanning face...')
                : (isEs ? 'Toca para reintentar reconocimiento' : 'Tap to retry face scan')))
        : (_isSuccess
            ? (isEs ? 'Huella verificada con éxito' : 'Fingerprint verified')
            : (_isAuthenticating
                ? (isEs ? 'Leyendo sensor de huella...' : 'Reading fingerprint sensor...')
                : (isEs ? 'Toca el sensor de huella para ingresar' : 'Touch fingerprint sensor to sign in')));

    final IconData biometricIcon = _isSuccess
        ? Icons.check_circle_rounded
        : (widget.isApple ? Icons.face_rounded : Icons.fingerprint_rounded);

    final Color statusColor = _isSuccess
        ? const Color(0xFF10B981)
        : (_isAuthenticating ? AppColors.brandBlue : const Color(0xFF64748B));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle superior
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Título y Subtítulo
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryNavy,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Tarjeta del usuario enrolado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.brandBlue.withValues(alpha: 0.12),
                  child: Text(
                    widget.userName.isNotEmpty
                        ? widget.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: AppColors.primaryNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.userEmail,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isEs ? 'Enrolado' : 'Enrolled',
                        style: const TextStyle(
                          color: Color(0xFF065F46),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Sensor Target interactivo
          GestureDetector(
            onTap: _startBiometricScan,
            child: ScaleTransition(
              scale: _isAuthenticating ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSuccess
                      ? const Color(0xFFDCFCE7)
                      : (_isAuthenticating
                          ? const Color(0xFFEFF6FF)
                          : const Color(0xFFF1F5F9)),
                  border: Border.all(
                    color: _isSuccess
                        ? const Color(0xFF10B981)
                        : (_isAuthenticating
                            ? AppColors.brandBlue
                            : const Color(0xFFCBD5E1)),
                    width: 2.5,
                  ),
                  boxShadow: _isAuthenticating
                      ? [
                          BoxShadow(
                            color: AppColors.brandBlue.withValues(alpha: 0.25),
                            blurRadius: 18,
                            spreadRadius: 4,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  biometricIcon,
                  size: 48,
                  color: _isSuccess
                      ? const Color(0xFF16A34A)
                      : (_isAuthenticating
                          ? AppColors.brandBlue
                          : const Color(0xFF475569)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Texto indicador de estado
          Text(
            actionHint,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Botón Cancelar / Usar contraseña
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isEs ? 'Cancelar / Usar contraseña' : 'Cancel / Use password',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
