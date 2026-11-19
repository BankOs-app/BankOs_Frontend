class RegisteredBankEntity {
  final String id;
  final String name;
  final String code;
  final String tenantId;
  final String currency;
  final bool isGlobal;

  const RegisteredBankEntity({
    required this.id,
    required this.name,
    required this.code,
    this.tenantId = 'tenant_bancolombia',
    this.currency = 'COP',
    this.isGlobal = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisteredBankEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
