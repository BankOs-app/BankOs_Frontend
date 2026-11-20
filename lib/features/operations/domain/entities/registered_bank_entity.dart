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

  static const List<RegisteredBankEntity> defaultBanks = [
    RegisteredBankEntity(
      id: '4f2a0415-2697-42d7-878d-ab67a1f6a657',
      name: 'Bancolombia',
      code: 'banco-lombia',
      tenantId: 'tenant_banco_lombia',
      currency: 'COP',
      primaryColorHex: '#000000',
      accentColorHex: '#FDDA24',
      logoKey: 'bancolombia',
    ),
    RegisteredBankEntity(
      id: '11111111-1111-4111-8111-111111111111',
      name: 'Banco de Bogotá',
      code: 'banco-bogota',
      tenantId: 'tenant_banco_bogota',
      currency: 'COP',
      primaryColorHex: '#002D72',
      accentColorHex: '#004BB1',
      logoKey: 'banco-bogota',
    ),
    RegisteredBankEntity(
      id: '22222222-2222-4222-8222-222222222222',
      name: 'Banco Santander',
      code: 'banco-santander',
      tenantId: 'tenant_banco_santander',
      currency: 'USD',
      primaryColorHex: '#EC0000',
      accentColorHex: '#CC0000',
      logoKey: 'banco-santander',
    ),
    RegisteredBankEntity(
      id: '47130a5f-3368-4a0b-ab77-0982b6a07a96',
      name: 'Banco de NU',
      code: 'banco-nu',
      tenantId: 'tenant_banco_nu',
      currency: 'COP',
      primaryColorHex: '#820AD1',
      accentColorHex: '#9B3FE6',
      logoKey: 'banco-nu',
    ),
    RegisteredBankEntity(
      id: 'e3a4a8cc-5551-400b-beb5-6b5ced30c7e0',
      name: 'Banco de Occidente',
      code: 'banco-occidente',
      tenantId: 'tenant_banco_occidente',
      currency: 'COP',
      primaryColorHex: '#0A2540',
      accentColorHex: '#0052FF',
      logoKey: 'bankos',
    ),
    RegisteredBankEntity(
      id: 'bank_bankos_global',
      name: 'BankOs Core Global',
      code: 'BOS',
      tenantId: 'tenant_bankos_global',
      currency: 'USD',
      isGlobal: true,
      primaryColorHex: '#031633',
      accentColorHex: '#6DA5FA',
      logoKey: 'bankos',
    ),
  ];

  static List<RegisteredBankEntity> get preloadedCommercialBanks =>
      defaultBanks.where((b) => !b.isGlobal).toList();

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
