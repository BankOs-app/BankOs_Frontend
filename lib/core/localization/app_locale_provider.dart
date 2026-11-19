import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { es, en }

class LocaleNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    return AppLanguage.es;
  }

  void setLanguage(AppLanguage language) {
    state = language;
  }

  void toggleLanguage() {
    state = state == AppLanguage.es ? AppLanguage.en : AppLanguage.es;
  }

  bool get isSpanish => state == AppLanguage.es;
  bool get isEnglish => state == AppLanguage.en;
}

final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, AppLanguage>(() {
  return LocaleNotifier();
});

class Tr {
  static bool _es(AppLanguage lang) => lang == AppLanguage.es;

  // General & Navigation
  static String home(AppLanguage lang) => _es(lang) ? 'Inicio' : 'Home';
  static String history(AppLanguage lang) => _es(lang) ? 'Historial' : 'History';
  static String profile(AppLanguage lang) => _es(lang) ? 'Perfil' : 'Profile';
  static String deposit(AppLanguage lang) => _es(lang) ? 'Depósito' : 'Deposit';
  static String withdraw(AppLanguage lang) => _es(lang) ? 'Retiro' : 'Withdraw';
  static String myAccounts(AppLanguage lang) => _es(lang) ? 'Mis Cuentas' : 'My Accounts';
  static String settings(AppLanguage lang) => _es(lang) ? 'Configuración' : 'Settings';
  static String security(AppLanguage lang) => _es(lang) ? 'Seguridad' : 'Security';
  static String personalData(AppLanguage lang) => _es(lang) ? 'Datos personales' : 'Personal Data';
  static String help(AppLanguage lang) => _es(lang) ? 'Ayuda' : 'Help & Support';
  static String logout(AppLanguage lang) => _es(lang) ? 'Cerrar sesión' : 'Log Out';
  static String cancel(AppLanguage lang) => _es(lang) ? 'Cancelar' : 'Cancel';
  static String save(AppLanguage lang) => _es(lang) ? 'Guardar' : 'Save';
  static String close(AppLanguage lang) => _es(lang) ? 'Cerrar' : 'Close';
  static String change(AppLanguage lang) => _es(lang) ? 'Cambiar' : 'Switch';
  static String language(AppLanguage lang) => _es(lang) ? 'Idioma' : 'Language';
  static String appLanguage(AppLanguage lang) => _es(lang) ? 'Idioma de la Aplicación' : 'Application Language';
  static String systemLanguage(AppLanguage lang) => _es(lang) ? 'Idioma del Sistema' : 'System Language';
  static String systemLanguageSub(AppLanguage lang) => _es(lang)
      ? 'Cambia el idioma para la consola de administración y todos los perfiles.'
      : 'Change language for the admin console and all profiles.';

  // Home / Dashboard
  static String greeting(AppLanguage lang, String name) => _es(lang) ? '¡Hola, $name!' : 'Hello, $name!';
  static String welcome(AppLanguage lang) => _es(lang) ? 'Bienvenida a BankOs' : 'Welcome to BankOs';
  static String availableBalance(AppLanguage lang) => _es(lang) ? 'Dinero actual:' : 'Current balance:';
  static String savingsAccount(AppLanguage lang) => _es(lang) ? 'Cuenta de ahorros' : 'Savings account';
  static String financialOps(AppLanguage lang) => _es(lang) ? 'Operaciones Financieras' : 'Financial Operations';
  static String recentTransactions(AppLanguage lang) => _es(lang) ? 'Transacciones hechas' : 'Recent Transactions';
  static String viewAll(AppLanguage lang) => _es(lang) ? 'Ver todas' : 'View all';
  static String noTransactions(AppLanguage lang) => _es(lang) ? 'No tienes transacciones registradas aún.' : 'No transactions recorded yet.';
  static String globalHub(AppLanguage lang) => _es(lang) ? 'Hub Multidivisa BankOs' : 'BankOs Multi-currency Hub';
  static String titularAccount(AppLanguage lang, String curr) => _es(lang) ? 'Cuenta del Titular ($curr)' : 'Titular Account ($curr)';
  static String myTitularAccounts(AppLanguage lang) => _es(lang) ? 'Cuentas y Bancos Registrados' : 'Registered Accounts & Banks';
  static String globalAccountTitle(AppLanguage lang) => _es(lang) ? 'CUENTA GLOBAL PRINCIPAL' : 'PRIMARY GLOBAL ACCOUNT';
  static String otherBanks(AppLanguage lang) => _es(lang) ? 'CUENTAS PERSONALES DE OTROS BANCOS' : 'PERSONAL ACCOUNTS IN OTHER BANKS';

  // Admin
  static String adminCreate(AppLanguage lang) => _es(lang) ? 'Crear' : 'Create';
  static String adminConfig(AppLanguage lang) => _es(lang) ? 'Config' : 'Settings';
  static String adminAudit(AppLanguage lang) => _es(lang) ? 'Auditoría' : 'Audit';
  static String adminOps(AppLanguage lang) => _es(lang) ? 'Operaciones' : 'Operations';
  static String adminProfile(AppLanguage lang) => _es(lang) ? 'Perfil' : 'Profile';
  static String adminTitle(AppLanguage lang) => _es(lang) ? 'Gestión de Tenants Bancarios' : 'Banking Tenants Management';
  static String adminSubtitle(AppLanguage lang) => _es(lang) ? 'Aprovisiona y administra instituciones financieras en BankOs BaaS.' : 'Provision and manage financial institutions on BankOs BaaS.';
  static String activeTenants(AppLanguage lang) => _es(lang) ? 'Tenants Activos' : 'Active Tenants';
  static String baasVolume(AppLanguage lang) => _es(lang) ? 'Volumen BaaS' : 'BaaS Volume';
  static String isolation(AppLanguage lang) => _es(lang) ? 'Aislamiento' : 'Isolation';
  static String createNewBank(AppLanguage lang) => _es(lang) ? '+ Crear Nuevo Banco (Tenant)' : '+ Create New Bank (Tenant)';
  static String registeredTenants(AppLanguage lang) => _es(lang) ? 'Instituciones Registradas' : 'Registered Institutions';
  static String operational(AppLanguage lang) => _es(lang) ? 'OPERATIVO' : 'OPERATIONAL';
  static String activeCount(AppLanguage lang, int count) => _es(lang) ? '$count Activas' : '$count Active';

  // Admin - Config Tab
  static String tenantConfig(AppLanguage lang) => _es(lang) ? 'Configuración del Tenant' : 'Tenant Settings';
  static String tenantConfigSubtitle(AppLanguage lang, String name) => _es(lang) ? 'Parámetros operativos de $name' : 'Operational parameters for $name';
  static String transferFeeLabel(AppLanguage lang) => _es(lang) ? 'Comisión por Transferencia Interna (%):' : 'Internal Transfer Fee (%):';
  static String dailyLimitLabel(AppLanguage lang) => _es(lang) ? 'Límite Diario Operativo por Cuenta:' : 'Daily Account Limit:';
  static String requireBiometrics(AppLanguage lang) => _es(lang) ? 'Requerir Biometría / MFA Obligatorio' : 'Require Biometrics / Mandatory MFA';
  static String requireBiometricsSub(AppLanguage lang) => _es(lang) ? 'Exigir validación biométrica en retiros y transferencias.' : 'Require biometric validation on withdrawals and transfers.';
  static String enabledModules(AppLanguage lang) => _es(lang) ? 'Módulos BaaS Habilitados:' : 'Enabled BaaS Modules:';
  static String saveTenantConfig(AppLanguage lang) => _es(lang) ? 'Guardar Configuraciones del Tenant' : 'Save Tenant Settings';

  // Admin - Audit Tab
  static String auditTitle(AppLanguage lang) => _es(lang) ? 'Auditar Logs de Seguridad' : 'Audit Security Logs';
  static String auditSubtitle(AppLanguage lang, String name) => _es(lang) ? 'Trazabilidad y eventos de seguridad en $name.' : 'Traceability and security events in $name.';
  static String filterAll(AppLanguage lang) => _es(lang) ? 'Todos' : 'All';

  // Admin - Operations Tab
  static String institutionOps(AppLanguage lang) => _es(lang) ? 'Operaciones de la Institución' : 'Institution Operations';
  static String ledgerGeneral(AppLanguage lang, String name) => _es(lang) ? 'Ledger general de $name' : 'General ledger of $name';
  static String totalRecords(AppLanguage lang) => _es(lang) ? 'Total Registros' : 'Total Records';
  static String status(AppLanguage lang) => _es(lang) ? 'Estado' : 'Status';
  static String conciliated(AppLanguage lang) => _es(lang) ? '100% Conciliado' : '100% Reconciled';
  static String baseCurrency(AppLanguage lang) => _es(lang) ? 'Divisa Base' : 'Base Currency';
  static String filterOpsAll(AppLanguage lang) => _es(lang) ? 'Todas' : 'All';
  static String filterDeposits(AppLanguage lang) => _es(lang) ? 'Depósitos' : 'Deposits';
  static String filterWithdrawals(AppLanguage lang) => _es(lang) ? 'Retiros' : 'Withdrawals';
  static String filterTransfers(AppLanguage lang) => _es(lang) ? 'Transferencias' : 'Transfers';
  static String noOpsTenant(AppLanguage lang) => _es(lang) ? 'No hay transacciones registradas en este tenant.' : 'No transactions recorded in this tenant.';

  // Admin - Profile Tab
  static String adminProfileTitle(AppLanguage lang) => _es(lang) ? 'Perfil del Administrador' : 'Administrator Profile';
  static String adminProfileSub(AppLanguage lang) => _es(lang) ? 'Credenciales institucionales, permisos y sesión activa.' : 'Institutional credentials, permissions and active session.';
  static String adminRole(AppLanguage lang) => _es(lang) ? 'Super-Administrador BankOs BaaS' : 'Super-Administrator BankOs BaaS';
  static String idBadge(AppLanguage lang) => _es(lang) ? 'ID de Matrícula' : 'License ID';
  static String assignedEntity(AppLanguage lang) => _es(lang) ? 'Entidad Asignada' : 'Assigned Entity';
  static String tenantIdLabel(AppLanguage lang) => _es(lang) ? 'ID de Tenant' : 'Tenant ID';
  static String activeRegion(AppLanguage lang) => _es(lang) ? 'Región Activa' : 'Active Region';
  static String accessLevel(AppLanguage lang) => _es(lang) ? 'Nivel de Acceso' : 'Access Level';
  static String logoutConfirm(AppLanguage lang) => _es(lang) ? 'Cerrar Sesión Institucional' : 'Sign Out Institutional Session';
  static String logoutAdminMessage(AppLanguage lang) => _es(lang)
      ? '¿Estás seguro de que deseas salir de la consola de administración de BankOs? Se cerrará la sesión de Super-Admin.'
      : 'Are you sure you want to sign out from the BankOs admin console? The Super-Admin session will be closed.';

  // Admin - Modal Crear Tenant
  static String modalCreateTitle(AppLanguage lang) => _es(lang) ? 'Crear Nuevo Banco (Tenant)' : 'Create New Bank (Tenant)';
  static String modalCreateSub(AppLanguage lang) => _es(lang) ? 'Aprovisiona una nueva institución financiera en BankOs Cloud.' : 'Provision a new financial institution on BankOs Cloud.';
  static String bankNameLabel(AppLanguage lang) => _es(lang) ? 'Nombre del Banco o Entidad:' : 'Bank or Entity Name:';
  static String codeLabel(AppLanguage lang) => _es(lang) ? 'Código / Tenant ID:' : 'Code / Tenant ID:';
  static String currencyLabel(AppLanguage lang) => _es(lang) ? 'Divisa Base Operativa:' : 'Base Operating Currency:';
  static String subdomainLabel(AppLanguage lang) => _es(lang) ? 'Subdominio asignado:' : 'Assigned subdomain:';
  static String isolationInfo(AppLanguage lang) => _es(lang) ? 'Aislamiento 100% RLS + Esquema Dedicado por Tenant.' : '100% RLS Isolation + Dedicated Schema per Tenant.';
  static String provisionButton(AppLanguage lang) => _es(lang) ? 'Aprovisionar y Crear Banco (Tenant)' : 'Provision and Create Bank (Tenant)';

  // Operations
  static String depositFunds(AppLanguage lang) => _es(lang) ? 'Depósito de Fondos' : 'Funds Deposit';
  static String withdrawFunds(AppLanguage lang) => _es(lang) ? 'Retiro de Fondos' : 'Funds Withdrawal';
  static String originAccount(AppLanguage lang) => _es(lang) ? '1. Cuenta de origen (De dónde saldrán los fondos):' : '1. Origin account (Source of funds):';
  static String destAccount(AppLanguage lang) => _es(lang) ? '2. Cuenta destino (A dónde se van los fondos):' : '2. Destination account (Where funds go):';
  static String depositAmount(AppLanguage lang) => _es(lang) ? '3. Monto a depositar:' : '3. Amount to deposit:';
  static String withdrawAmount(AppLanguage lang) => _es(lang) ? '4. Monto a retirar:' : '4. Amount to withdraw:';
  static String conceptOptional(AppLanguage lang) => _es(lang) ? 'Concepto (opcional):' : 'Concept (optional):';
  static String confirmDeposit(AppLanguage lang) => _es(lang) ? 'Confirmar Depósito' : 'Confirm Deposit';
  static String confirmWithdraw(AppLanguage lang) => _es(lang) ? 'Confirmar Retiro' : 'Confirm Withdrawal';
  static String withdrawBankLabel(AppLanguage lang) => _es(lang) ? '1. Banco registrado:' : '1. Registered bank:';
  static String withdrawCardLabel(AppLanguage lang) => _es(lang) ? '2. Tarjetas anexadas a este banco:' : '2. Cards attached to this bank:';
  static String withdrawCurrencyLabel(AppLanguage lang) => _es(lang) ? '3. Divisa a retirar:' : '3. Currency to withdraw:';

  // Conversion Card
  static String conversionTitle(AppLanguage lang) => _es(lang) ? 'Conversión a Dólares y Euros (Tiempo Real):' : 'Real-Time Dollar & Euro Conversion:';
  static String inDollars(AppLanguage lang) => _es(lang) ? 'En Dólares' : 'In Dollars';
  static String inEuros(AppLanguage lang) => _es(lang) ? 'En Euros' : 'In Euros';
  static String estimatedDestination(AppLanguage lang, String dest) => _es(lang) ? 'Abono estimado en destino ($dest):' : 'Estimated credit at destination ($dest):';
  static String tenantRatesLabel(AppLanguage lang) => _es(lang) ? 'Tasas Tenant: 1 USD ≈ \$4,150 COP • 1 EUR ≈ 1.08 USD' : 'Tenant Rates: 1 USD ≈ \$4,150 COP • 1 EUR ≈ 1.08 USD';
  static String noHiddenSpread(AppLanguage lang) => _es(lang) ? 'Sin spread oculto' : 'No hidden spread';

  // History Screen
  static String historyTitle(AppLanguage lang) => _es(lang) ? 'Historial de Operaciones' : 'Operations History';
  static String searchMovement(AppLanguage lang) => _es(lang) ? 'Buscar movimiento...' : 'Search transactions...';
  static String filterHistoryAll(AppLanguage lang) => _es(lang) ? 'Todos' : 'All';
  static String filterHistoryDeposits(AppLanguage lang) => _es(lang) ? 'Depósitos' : 'Deposits';
  static String filterHistoryWithdrawals(AppLanguage lang) => _es(lang) ? 'Retiros' : 'Withdrawals';
  static String filterHistoryExchange(AppLanguage lang) => _es(lang) ? 'Cambio Divisa' : 'Currency Exchange';
}
