import 'dart:convert';
import 'package:material_ui/material_ui.dart';
import '../constants/app_colors.dart';
import '../../features/operations/domain/entities/registered_bank_entity.dart';
import 'bankos_logo.dart';

/// Emblema / Logo institucional reactivo según el banco activo.
/// Soporta logos subidos por URL, base64 y emblemas vectoriales predeterminados.
class BankBrandLogo extends StatelessWidget {
  final RegisteredBankEntity? bank;
  final double size;
  final bool showName;
  final Color? textColor;
  final double fontSize;

  const BankBrandLogo({
    super.key,
    this.bank,
    this.size = 28.0,
    this.showName = true,
    this.textColor,
    this.fontSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    final b = bank;
    final logoIcon = _buildEmblem(b);

    if (!showName) return logoIcon;

    final name = (b == null || b.isGlobal) ? 'BankOs' : b.name;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoIcon,
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            name,
            style: TextStyle(
              color: textColor ?? AppColors.primaryNavy,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmblem(RegisteredBankEntity? b) {
    if (b == null || b.isGlobal) {
      return BankOsLogo(
        iconSize: size,
        fontSize: 0,
        showText: false,
      );
    }

    final key = b.logoKey.trim();

    // 1. Imagen subida por URL (http / https)
    if (key.startsWith('http://') || key.startsWith('https://')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size * 0.25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          key,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildFallbackBadge(b),
        ),
      );
    }

    // 2. Imagen en base64 (Data URI)
    if (key.startsWith('data:image')) {
      try {
        final commaIdx = key.indexOf(',');
        final base64Str = commaIdx != -1 ? key.substring(commaIdx + 1) : key;
        final bytes = base64Decode(base64Str.trim());
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => _buildFallbackBadge(b),
          ),
        );
      } catch (_) {
        return _buildFallbackBadge(b);
      }
    }

    // 3. Emblemas institucionales predeterminados
    final lowerKey = key.toLowerCase();
    final lowerName = b.name.toLowerCase();

    if (lowerKey.contains('lombia') || lowerName.contains('bancolombia')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: size * 0.52,
            height: size * 0.52,
            decoration: const BoxDecoration(
              color: Color(0xFFFDDA24), // Amarillo Bancolombia
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: size * 0.22,
                height: size * 0.22,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    if (lowerKey.contains('bogota') || lowerName.contains('bogot')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF002D72), // Azul Bogotá
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF002D72).withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.account_balance_rounded,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
      );
    }

    if (lowerKey.contains('santander') || lowerName.contains('santander')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFEC0000), // Rojo Santander
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC0000).withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: size * 0.58,
          ),
        ),
      );
    }

    if (lowerKey.contains('nu') || lowerName.contains('nu')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF820AD1), // Violeta Nu
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF820AD1).withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'nu',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.45,
              fontStyle: FontStyle.italic,
              letterSpacing: -1,
            ),
          ),
        ),
      );
    }

    if (lowerKey.contains('davivienda') || lowerName.contains('davivienda')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFED1C24),
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFED1C24).withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.home_rounded,
            color: Colors.white,
            size: size * 0.58,
          ),
        ),
      );
    }

    if (lowerKey.contains('bbva') || lowerName.contains('bbva')) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF004481),
          borderRadius: BorderRadius.circular(size * 0.28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004481).withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'BBVA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: size * 0.32,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    }

    if (lowerKey == 'bankos' || lowerKey.contains('bankos')) {
      return BankOsLogo(
        iconSize: size,
        fontSize: 0,
        showText: false,
      );
    }

    // Fallback general elegante
    return _buildFallbackBadge(b);
  }

  Widget _buildFallbackBadge(RegisteredBankEntity b) {
    Color bg = AppColors.primaryNavy;
    try {
      if (b.primaryColorHex.isNotEmpty) {
        bg = Color(int.parse(b.primaryColorHex.replaceFirst('#', '0xFF')));
      }
    } catch (_) {}

    final initial = b.name.isNotEmpty ? b.name[0].toUpperCase() : 'B';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.5,
          ),
        ),
      ),
    );
  }
}
