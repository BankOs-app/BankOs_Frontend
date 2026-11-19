import 'package:material_ui/material_ui.dart';

class RegisteredBankEntity {
  final String id;
  final String name;
  final String code;
  final String tenantId;
  final String currency;
  final bool isGlobal;
  final String primaryColorHex;
  final String accentColorHex;
  final String logoKey;

  const RegisteredBankEntity({
    required this.id,
    required this.name,
    required this.code,
    this.tenantId = 'tenant_bancolombia',
    this.currency = 'COP',
    this.isGlobal = false,
    this.primaryColorHex = '#0A2540',
    this.accentColorHex = '#0052FF',
    this.logoKey = 'bankos',
  });

  Color get primaryColor => _parseColor(primaryColorHex, const Color(0xFF0A2540));
  Color get accentColor => _parseColor(accentColorHex, const Color(0xFF0052FF));
  Color get primaryColorParsed => primaryColor;
  Color get accentColorParsed => accentColor;

  static Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final clean = hex.replaceAll('#', '').trim();
    if (clean.length == 6) {
      final val = int.tryParse('FF$clean', radix: 16);
      if (val != null) return Color(val);
    } else if (clean.length == 8) {
      final val = int.tryParse(clean, radix: 16);
      if (val != null) return Color(val);
    }
    return fallback;
  }

  RegisteredBankEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? tenantId,
    String? currency,
    bool? isGlobal,
    String? primaryColorHex,
    String? accentColorHex,
    String? logoKey,
  }) {
    return RegisteredBankEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      tenantId: tenantId ?? this.tenantId,
      currency: currency ?? this.currency,
      isGlobal: isGlobal ?? this.isGlobal,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      logoKey: logoKey ?? this.logoKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisteredBankEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
