import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { es, en }

class LocaleNotifier extends Notifier<AppLanguage> {
  static AppLanguage currentLanguage = AppLanguage.es;

  @override
  AppLanguage build() {
    currentLanguage = AppLanguage.es;
    return AppLanguage.es;
  }

  void setLanguage(AppLanguage language) {
    currentLanguage = language;
    state = language;
  }

  void toggleLanguage() {
    state = state == AppLanguage.es ? AppLanguage.en : AppLanguage.es;
    currentLanguage = state;
  }

  bool get isSpanish => state == AppLanguage.es;
  bool get isEnglish => state == AppLanguage.en;
}

final localeNotifierProvider = NotifierProvider<LocaleNotifier, AppLanguage>(
  () {
    return LocaleNotifier();
  },
);

class Tr {
  static bool _es(AppLanguage lang) => lang == AppLanguage.es;

  static String onboardingTitle(AppLanguage lang, int index) => _es(lang)
      ? const [
          'Banca digital\nsegura',
          'Haz crecer\ntu dinero',
          'Todo en un\nsolo lugar',
        ][index]
      : const [
          'Secure digital\nbanking',
          'Grow\nyour money',
          'Everything in\none place',
        ][index];
  static String onboardingSubtitle(AppLanguage lang, int index) => _es(lang)
      ? const [
          'Tu dinero y tu información protegidos con tecnología de última generación.',
          'Ahorra, invierte y alcanza tus metas con herramientas simples y transparentes.',
          'Tarjetas, transferencias, pagos y más, desde una sola app.',
        ][index]
      : const [
          'Your money and information are protected with modern security technology.',
          'Save, invest, and reach your goals with simple, transparent tools.',
          'Cards, transfers, payments, and more in one app.',
        ][index];
  static String launchSubtitle(AppLanguage lang) => _es(lang)
      ? 'Tu banco digital,\nsiempre contigo'
      : 'Your digital bank,\nalways with you';
  static String skip(AppLanguage lang) => _es(lang) ? 'Omitir' : 'Skip';
  static String start(AppLanguage lang) =>
      _es(lang) ? 'Comenzar' : 'Get started';
  static String next(AppLanguage lang) => _es(lang) ? 'Siguiente' : 'Next';
  static String selectInstitution(AppLanguage lang) =>
      _es(lang) ? 'Seleccionar entidad' : 'Select an institution';
  static String selectInstitutionSub(AppLanguage lang) => _es(lang)
      ? 'Conéctate a tu institución financiera para operar de forma segura.'
      : 'Choose your financial institution to bank securely.';
  static String bankCurrencyAccount(AppLanguage lang, String currency) =>
      _es(lang) ? 'Cuenta en $currency' : '$currency account';
  static String secureDigitalBanking(AppLanguage lang) =>
      _es(lang) ? 'Banca digital segura' : 'Secure digital banking';
  static String superAdminConsole(AppLanguage lang) => _es(lang)
      ? 'Consola para Administrador General'
      : 'General Administrator Console';
  static String superAdminLabel(AppLanguage lang) =>
      _es(lang) ? 'Administrador general' : 'SuperAdmin';
  static String chooseAnotherBank(AppLanguage lang) =>
      _es(lang) ? 'Elegir otro banco' : 'Choose another bank';
  static String loginTitle(AppLanguage lang) =>
      _es(lang) ? 'Iniciar sesión' : 'Sign in';
  static String loginSub(AppLanguage lang, String bank) => _es(lang)
      ? 'Ingresa a tu cuenta de $bank de forma segura.'
      : 'Sign in securely to your $bank account.';
  static String superAdminLoginSub(AppLanguage lang) => _es(lang)
      ? 'Ingresa tus credenciales de Administrador General para operar de forma segura.'
      : 'Sign in with your General Administrator credentials.';
  static String email(AppLanguage lang) =>
      _es(lang) ? 'Correo electrónico' : 'Email address';
  static String password(AppLanguage lang) =>
      _es(lang) ? 'Contraseña' : 'Password';
  static String forgotPassword(AppLanguage lang) =>
      _es(lang) ? '¿Olvidaste tu contraseña?' : 'Forgot your password?';
  static String biometricLogin(AppLanguage lang, bool isApple) => _es(lang)
      ? (isApple ? 'Ingresar con Face ID' : 'Ingresar con huella dactilar')
      : (isApple ? 'Sign in with Face ID' : 'Sign in with fingerprint');
  static String biometricDisabled(AppLanguage lang, bool isApple) => _es(lang)
      ? (isApple
            ? 'Face ID está desactivado. Inicia sesión con tus credenciales para activarlo.'
            : 'La huella dactilar está desactivada. Inicia sesión con tus credenciales para activarla.')
      : (isApple
            ? 'Face ID is disabled. Sign in with your credentials to enable it.'
            : 'Fingerprint sign-in is disabled. Sign in with your credentials to enable it.');
  static String biometricUnavailable(AppLanguage lang) => _es(lang)
      ? 'La autenticación biométrica está desactivada. Inicia sesión con tus credenciales y actívala en tu perfil.'
      : 'Biometric sign-in is disabled. Sign in with your credentials and enable it in your profile.';
  static String biometricLoginRequired(AppLanguage lang) => _es(lang)
      ? 'Inicia sesión con las credenciales del banco seleccionado para activar la autenticación biométrica.'
      : 'Sign in with the selected bank credentials to enable biometric authentication.';
  static String noAccount(AppLanguage lang) =>
      _es(lang) ? '¿Aún no tienes cuenta? ' : 'Don’t have an account? ';
  static String register(AppLanguage lang) =>
      _es(lang) ? 'Registrarse' : 'Create account';
  static String requiredEmail(AppLanguage lang) => _es(lang)
      ? 'Ingresa tu correo electrónico.'
      : 'Enter your email address.';
  static String requiredPassword(AppLanguage lang) =>
      _es(lang) ? 'Ingresa tu contraseña.' : 'Enter your password.';
  static String forgotTitle(AppLanguage lang) =>
      _es(lang) ? 'Recuperar contraseña' : 'Reset password';
  static String forgotSub(AppLanguage lang) => _es(lang)
      ? 'Ingresa tu correo electrónico para la recuperación'
      : 'Enter your email address to recover your account';
  static String recoveryInstructions(AppLanguage lang, String bank) => _es(lang)
      ? 'Te enviaremos las instrucciones de recuperación al correo registrado en $bank.'
      : 'We will send recovery instructions to the email registered with $bank.';
  static String sendRecovery(AppLanguage lang) => _es(lang)
      ? 'Enviar instrucciones de recuperación'
      : 'Send recovery instructions';
  static String recoverySent(AppLanguage lang) =>
      _es(lang) ? 'Solicitud recibida' : 'Request received';
  static String recoverySentSub(AppLanguage lang, String emailAddress) =>
      _es(lang)
      ? 'Si la dirección $emailAddress está registrada, recibirás instrucciones para recuperar tu acceso.'
      : 'If $emailAddress is registered, you will receive instructions to recover your access.';
  static String backToLogin(AppLanguage lang) =>
      _es(lang) ? 'Volver al inicio de sesión' : 'Back to sign in';
  static String dashboardGreeting(AppLanguage lang) =>
      _es(lang) ? 'Hola, bienvenido' : 'Hello, welcome';
  static String dashboardWelcome(AppLanguage lang) => _es(lang)
      ? 'Aquí está el resumen de tu cuenta.'
      : 'Here is your account overview.';
  static String quickActions(AppLanguage lang) =>
      _es(lang) ? 'Accesos rápidos' : 'Quick actions';
  static String transfer(AppLanguage lang) =>
      _es(lang) ? 'Transferir' : 'Transfer';
  static String transferFunds(AppLanguage lang) =>
      _es(lang) ? 'Transferencia de fondos' : 'Funds transfer';
  static String transferSourceAccount(AppLanguage lang) => _es(lang)
      ? '1. Cuenta de origen (desde donde se enviarán los fondos):'
      : '1. Source account (where funds will be sent from):';
  static String transferDestinationAccount(AppLanguage lang) => _es(lang)
      ? '2. Cuenta destino (donde se recibirán los fondos):'
      : '2. Destination account (where funds will be received):';
  static String noSessionAccount(AppLanguage lang, String bank) => _es(lang)
      ? 'No hay una cuenta asociada a esta sesión en $bank.'
      : 'There is no account associated with this session at $bank.';
  static String destinationAccountHint(AppLanguage lang) =>
      _es(lang) ? 'Escribe el número de cuenta' : 'Enter the account number';
  static String destinationNotFound(AppLanguage lang) => _es(lang)
      ? 'No encontramos una cuenta con ese número.'
      : 'No account was found with that number.';
  static String destinationNumberInvalid(AppLanguage lang) => _es(lang)
      ? 'Ingresa un número de cuenta válido (solo números).'
      : 'Enter a valid account number using digits only.';
  static String destinationAmbiguous(AppLanguage lang) => _es(lang)
      ? 'El número de cuenta no identifica una única cuenta destino.'
      : 'This account number does not identify a unique destination account.';
  static String destinationBankNotFound(AppLanguage lang) => _es(lang)
      ? 'No encontramos el banco de la cuenta destino.'
      : 'The destination account bank could not be found.';
  static String sameAccountTransfer(AppLanguage lang) => _es(lang)
      ? 'La cuenta de origen y destino no pueden ser la misma.'
      : 'The source and destination accounts must be different.';
  static String sourceAccountInactive(AppLanguage lang) => _es(lang)
      ? 'La cuenta de origen no está activa.'
      : 'The source account is not active.';
  static String destinationAccountInactive(AppLanguage lang) => _es(lang)
      ? 'La cuenta destino no está activa.'
      : 'The destination account is not active.';
  static String transferInvalidAmount(AppLanguage lang) => _es(lang)
      ? 'Ingresa un monto numérico válido mayor que cero.'
      : 'Enter a valid amount greater than zero.';
  static String transferInsufficientFunds(
    AppLanguage lang,
    String bank,
    String balance,
  ) => _es(lang)
      ? 'Saldo insuficiente en $bank. Disponible: $balance.'
      : 'Insufficient balance at $bank. Available: $balance.';
  static String transferAmountLabel(AppLanguage lang) =>
      _es(lang) ? '3. Monto a transferir:' : '3. Transfer amount:';
  static String reviewTransfer(AppLanguage lang) => _es(lang)
      ? 'Continuar y revisar conversión'
      : 'Continue and review conversion';
  static String transferSummaryTitle(AppLanguage lang) => _es(lang)
      ? 'Detalle y moneda a recibir'
      : 'Transfer details and receiving currency';
  static String recipientWillReceive(AppLanguage lang) =>
      _es(lang) ? 'El destinatario recibirá:' : 'The recipient will receive:';
  static String sourceAccountLabel(AppLanguage lang) =>
      _es(lang) ? 'Cuenta de origen:' : 'Source account:';
  static String destinationAccountLabel(AppLanguage lang) =>
      _es(lang) ? 'Cuenta destino:' : 'Destination account:';
  static String amountDebitedLabel(AppLanguage lang) =>
      _es(lang) ? 'Monto debitado:' : 'Amount debited:';
  static String transferFeeLabelSummary(AppLanguage lang) =>
      _es(lang) ? 'Comisión de transferencia:' : 'Transfer fee:';
  static String noFee(AppLanguage lang) => _es(lang) ? 'Sin costo' : 'No fee';
  static String appliedExchangeRate(
    AppLanguage lang,
    String from,
    String rate,
    String to,
  ) => _es(lang)
      ? 'Tasa aplicada: 1 $from = $rate $to'
      : 'Applied rate: 1 $from = $rate $to';
  static String appliedExchangeRateText(AppLanguage lang, String rate) =>
      _es(lang) ? 'Tasa aplicada: $rate' : 'Applied rate: $rate';
  static String confirmSendFunds(AppLanguage lang) =>
      _es(lang) ? 'Confirmar y enviar fondos' : 'Confirm and send funds';
  static String transferTo(AppLanguage lang, String bank) =>
      _es(lang) ? 'Transferir a $bank' : 'Transfer to $bank';
  static String transferConcept(
    AppLanguage lang,
    String bank,
    String account,
  ) => _es(lang)
      ? 'Transferencia a $bank (No. $account)'
      : 'Transfer to $bank (No. $account)';
  static String transferConceptHint(AppLanguage lang) => _es(lang)
      ? 'Ej. Pago de servicios o envío a familiares'
      : 'E.g. Bill payment or transfer to family';
  static String transferSuccess(AppLanguage lang) =>
      _es(lang) ? 'Transferencia exitosa' : 'Transfer successful';
  static String transferReceipt(
    AppLanguage lang,
    String amount,
    String fromCurrency,
    String originBank,
    String destAmount,
    String toCurrency,
    String destBank,
    String account,
  ) => _es(lang)
      ? 'Se debitaron $amount $fromCurrency de tu cuenta en $originBank y se acreditaron $destAmount $toCurrency en la cuenta de $destBank (No. $account).'
      : '$amount $fromCurrency was debited from your $originBank account and $destAmount $toCurrency was credited to the $destBank account (No. $account).';
  static String sameCurrencyTransferReceipt(
    AppLanguage lang,
    String amount,
    String currency,
    String originBank,
    String destBank,
    String account,
  ) => _es(lang)
      ? 'Se transfirieron $amount $currency desde $originBank hacia $destBank (No. $account).'
      : '$amount $currency was transferred from $originBank to $destBank (No. $account).';
  static String authorizeOperation(AppLanguage lang) =>
      _es(lang) ? 'Autorizar operación' : 'Authorize operation';
  static String amountToProcess(AppLanguage lang) =>
      _es(lang) ? 'Monto a procesar:' : 'Amount to process:';
  static String cardType(AppLanguage lang, bool isCredit) => _es(lang)
      ? (isCredit ? 'Cuenta de crédito' : 'Cuenta de débito')
      : (isCredit ? 'Credit account' : 'Debit account');
  static String enterPin(AppLanguage lang) =>
      _es(lang) ? 'Ingresa tu PIN de 4 dígitos' : 'Enter your 4-digit PIN';
  static String pinSecuritySub(AppLanguage lang) => _es(lang)
      ? 'PIN de seguridad creado al registrarte'
      : 'Security PIN created during registration';
  static String pinIncorrect(AppLanguage lang) => _es(lang)
      ? 'PIN incorrecto. Inténtalo de nuevo.'
      : 'Incorrect PIN. Please try again.';
  static String receive(AppLanguage lang) => _es(lang) ? 'Recibir' : 'Receive';
  static String bills(AppLanguage lang) => _es(lang) ? 'Servicios' : 'Bills';
  static String more(AppLanguage lang) => _es(lang) ? 'Más' : 'More';
  static String noNotifications(AppLanguage lang) => _es(lang)
      ? 'No tienes notificaciones nuevas.'
      : 'You have no new notifications.';
  static String totalBalance(AppLanguage lang) =>
      _es(lang) ? 'Saldo total' : 'Total balance';
  static String activeAccountStatus(AppLanguage lang) =>
      _es(lang) ? 'Activa' : 'Active';
  static String defaultCheckingAccount(AppLanguage lang) =>
      _es(lang) ? 'Cuenta corriente' : 'Checking account';

  // General & Navigation
  static String home(AppLanguage lang) => _es(lang) ? 'Inicio' : 'Home';
  static String history(AppLanguage lang) =>
      _es(lang) ? 'Historial' : 'History';
  static String profile(AppLanguage lang) => _es(lang) ? 'Perfil' : 'Profile';
  static String myProfile(AppLanguage lang) =>
      _es(lang) ? 'Mi Perfil' : 'My Profile';
  static String deposit(AppLanguage lang) => _es(lang) ? 'Depósito' : 'Deposit';
  static String withdraw(AppLanguage lang) => _es(lang) ? 'Retiro' : 'Withdraw';
  static String myAccounts(AppLanguage lang) =>
      _es(lang) ? 'Mis Cuentas' : 'My Accounts';
  static String settings(AppLanguage lang) =>
      _es(lang) ? 'Configuración' : 'Settings';
  static String security(AppLanguage lang) =>
      _es(lang) ? 'Seguridad' : 'Security';
  static String personalData(AppLanguage lang) =>
      _es(lang) ? 'Datos personales' : 'Personal Data';
  static String institutionalData(AppLanguage lang) =>
      _es(lang) ? 'Datos Institucionales' : 'Institutional Data';
  static String help(AppLanguage lang) =>
      _es(lang) ? 'Ayuda y Soporte' : 'Help & Support';
  static String logout(AppLanguage lang) =>
      _es(lang) ? 'Cerrar sesión' : 'Log Out';
  static String cancel(AppLanguage lang) => _es(lang) ? 'Cancelar' : 'Cancel';
  static String save(AppLanguage lang) => _es(lang) ? 'Guardar' : 'Save';
  static String close(AppLanguage lang) => _es(lang) ? 'Cerrar' : 'Close';
  static String change(AppLanguage lang) => _es(lang) ? 'Cambiar' : 'Switch';
  static String language(AppLanguage lang) => _es(lang) ? 'Idioma' : 'Language';
  static String appLanguage(AppLanguage lang) =>
      _es(lang) ? 'Idioma de la Aplicación' : 'Application Language';
  static String systemLanguage(AppLanguage lang) =>
      _es(lang) ? 'Idioma del Sistema' : 'System Language';
  static String systemLanguageSub(AppLanguage lang) => _es(lang)
      ? 'Cambia el idioma para la consola de administración y todos los perfiles.'
      : 'Change language for the admin console and all profiles.';
  static String verifiedAccount(AppLanguage lang) =>
      _es(lang) ? 'Cuenta Verificada' : 'Verified Account';
  static String verified(AppLanguage lang) =>
      _es(lang) ? 'Verificado' : 'Verified';
  static String active2FA(AppLanguage lang) =>
      _es(lang) ? '2FA Activo' : '2FA Active';

  // Home / Dashboard
  static String greeting(AppLanguage lang, String name) =>
      _es(lang) ? '¡Hola, $name!' : 'Hello, $name!';
  static String welcome(AppLanguage lang) =>
      _es(lang) ? 'Bienvenida a BankOs' : 'Welcome to BankOs';
  static String availableBalance(AppLanguage lang) =>
      _es(lang) ? 'Dinero actual:' : 'Current balance:';
  static String savingsAccount(AppLanguage lang) =>
      _es(lang) ? 'Cuenta de ahorros' : 'Savings account';
  static String financialOps(AppLanguage lang) =>
      _es(lang) ? 'Operaciones Financieras' : 'Financial Operations';
  static String recentTransactions(AppLanguage lang) =>
      _es(lang) ? 'Transacciones hechas' : 'Recent Transactions';
  static String viewAll(AppLanguage lang) =>
      _es(lang) ? 'Ver todas' : 'View all';
  static String noTransactions(AppLanguage lang) => _es(lang)
      ? 'No tienes transacciones registradas aún.'
      : 'No transactions recorded yet.';
  static String globalHub(AppLanguage lang) =>
      _es(lang) ? 'Hub Multidivisa BankOs' : 'BankOs Multi-currency Hub';
  static String titularAccount(AppLanguage lang, String curr) =>
      _es(lang) ? 'Cuenta del Titular ($curr)' : 'Titular Account ($curr)';
  static String myTitularAccounts(AppLanguage lang) => _es(lang)
      ? 'Cuentas y Bancos Registrados'
      : 'Registered Accounts & Banks';
  static String globalAccountTitle(AppLanguage lang) =>
      _es(lang) ? 'CUENTA GLOBAL PRINCIPAL' : 'PRIMARY GLOBAL ACCOUNT';
  static String otherBanks(AppLanguage lang) => _es(lang)
      ? 'CUENTAS PERSONALES DE OTROS BANCOS'
      : 'PERSONAL ACCOUNTS IN OTHER BANKS';

  // Admin Navigation & Tabs
  static String adminCreate(AppLanguage lang) => _es(lang) ? 'Crear' : 'Create';
  static String adminConfig(AppLanguage lang) =>
      _es(lang) ? 'Config' : 'Settings';
  static String adminAudit(AppLanguage lang) =>
      _es(lang) ? 'Auditoría' : 'Audit';
  static String adminOps(AppLanguage lang) =>
      _es(lang) ? 'Operaciones' : 'Operations';
  static String adminProfile(AppLanguage lang) =>
      _es(lang) ? 'Perfil' : 'Profile';
  static String adminTitle(AppLanguage lang) => _es(lang)
      ? 'Gestión de Entidades Bancarias'
      : 'Banking Entities Management';
  static String adminSubtitle(AppLanguage lang) => _es(lang)
      ? 'Administra instituciones financieras autorizadas.'
      : 'Manage authorized financial institutions.';
  static String activeTenants(AppLanguage lang) =>
      _es(lang) ? 'Bancos Activos' : 'Active Banks';
  static String baasVolume(AppLanguage lang) =>
      _es(lang) ? 'Volumen BaaS' : 'BaaS Volume';
  static String isolation(AppLanguage lang) =>
      _es(lang) ? 'Seguridad' : 'Security';
  static String createNewBank(AppLanguage lang) =>
      _es(lang) ? '+ Crear Nuevo Banco' : '+ Create New Bank';
  static String registeredTenants(AppLanguage lang) =>
      _es(lang) ? 'Instituciones Registradas' : 'Registered Institutions';
  static String operational(AppLanguage lang) =>
      _es(lang) ? 'OPERATIVO' : 'OPERATIONAL';
  static String activeCount(AppLanguage lang, int count) =>
      _es(lang) ? '$count Activas' : '$count Active';

  // Admin - Config Tab
  static String tenantConfig(AppLanguage lang) =>
      _es(lang) ? 'Configuración Institucional' : 'Institutional Settings';
  static String tenantConfigSubtitle(AppLanguage lang, String name) => _es(lang)
      ? 'Parámetros operativos de $name'
      : 'Operational parameters for $name';
  static String transferFeeLabel(AppLanguage lang) => _es(lang)
      ? 'Comisión por Transferencia Interna (%):'
      : 'Internal Transfer Fee (%):';
  static String dailyLimitLabel(AppLanguage lang) => _es(lang)
      ? 'Límite Diario Operativo por Cuenta:'
      : 'Daily Account Limit:';
  static String requireBiometrics(AppLanguage lang) => _es(lang)
      ? 'Requerir Biometría / MFA Obligatorio'
      : 'Require Biometrics / Mandatory MFA';
  static String requireBiometricsSub(AppLanguage lang) => _es(lang)
      ? 'Exigir validación biométrica en retiros y transferencias.'
      : 'Require biometric validation on withdrawals and transfers.';
  static String enabledModules(AppLanguage lang) =>
      _es(lang) ? 'Módulos BaaS Habilitados:' : 'Enabled BaaS Modules:';
  static String saveTenantConfig(AppLanguage lang) =>
      _es(lang) ? 'Guardar Parámetros' : 'Save Parameters';

  // Admin - Audit Tab
  static String auditTitle(AppLanguage lang) =>
      _es(lang) ? 'Auditar Logs de Seguridad' : 'Audit Security Logs';
  static String auditSubtitle(AppLanguage lang, String name) => _es(lang)
      ? 'Trazabilidad y eventos de seguridad en $name.'
      : 'Traceability and security events in $name.';
  static String filterAll(AppLanguage lang) => _es(lang) ? 'Todos' : 'All';

  // Admin - Operations Tab & Ledger
  static String institutionOps(AppLanguage lang) =>
      _es(lang) ? 'Operaciones de la Institución' : 'Institution Operations';
  static String institutionOpsSubtitle(
    AppLanguage lang,
    String name,
    bool isSuper,
  ) => _es(lang)
      ? (isSuper
            ? 'Personalización visual de marca y auditoría contable por institución.'
            : 'Auditoría y consulta de libro mayor de $name.')
      : (isSuper
            ? 'Visual brand customization and accounting audit per institution.'
            : 'Accounting audit and general ledger for $name.');
  static String bankToManage(AppLanguage lang) => _es(lang)
      ? 'Institución Bancaria a Gestionar:'
      : 'Banking Institution to Manage:';
  static String customizeBrand(AppLanguage lang, String name) => _es(lang)
      ? 'Personalizar Marca y Colores ($name)'
      : 'Customize Brand & Colors ($name)';
  static String hideBrand(AppLanguage lang) => _es(lang)
      ? 'Ocultar Personalización de Marca'
      : 'Hide Brand Customization';
  static String ledgerTitle(AppLanguage lang, String name) =>
      _es(lang) ? 'Libro Mayor: $name' : 'General Ledger: $name';
  static String totalRecords(AppLanguage lang) =>
      _es(lang) ? 'Total Registros' : 'Total Records';
  static String totalAmount(AppLanguage lang) =>
      _es(lang) ? 'Monto Total' : 'Total Amount';
  static String status(AppLanguage lang) => _es(lang) ? 'Estado' : 'Status';
  static String conciliated(AppLanguage lang) =>
      _es(lang) ? '100% Conciliado' : '100% Reconciled';
  static String conciliatedBadge(AppLanguage lang) =>
      _es(lang) ? 'Conciliado' : 'Reconciled';
  static String baseCurrency(AppLanguage lang) =>
      _es(lang) ? 'Divisa Base' : 'Base Currency';
  static String filterOpsAll(AppLanguage lang) => _es(lang) ? 'Todas' : 'All';
  static String filterDeposits(AppLanguage lang) =>
      _es(lang) ? 'Depósitos' : 'Deposits';
  static String filterWithdrawals(AppLanguage lang) =>
      _es(lang) ? 'Retiros' : 'Withdrawals';
  static String filterTransfers(AppLanguage lang) =>
      _es(lang) ? 'Transferencias' : 'Transfers';
  static String noOpsTenant(AppLanguage lang) => _es(lang)
      ? 'No hay transacciones registradas en este banco.'
      : 'No transactions recorded for this bank.';
  static String bankLogoLabel(AppLanguage lang) =>
      _es(lang) ? 'Logotipo de la Institución:' : 'Institution Logo:';
  static String applyLogo(AppLanguage lang) =>
      _es(lang) ? 'Aplicar Logo' : 'Apply Logo';
  static String logoHint(AppLanguage lang) => _es(lang)
      ? 'Pegar URL o Base64 de imagen de logo'
      : 'Paste logo image URL or Base64';
  static String primaryColorLabel(AppLanguage lang) => _es(lang)
      ? 'Color Primario (Encabezados y Elementos Clave):'
      : 'Primary Color (Headers and Key Elements):';
  static String accentColorLabel(AppLanguage lang) => _es(lang)
      ? 'Color de Acento (Botones, Destacados y Acciones):'
      : 'Accent Color (Buttons, Highlights and Actions):';
  static String colorPaletteInstruction(AppLanguage lang) => _es(lang)
      ? 'Elige una bolita de color o créalo tú mismo con RGB:'
      : 'Choose a color circle or create it with RGB:';
  static String rgbCreatorLabel(AppLanguage lang) =>
      _es(lang) ? 'Creador RGB:' : 'RGB Creator:';
  static String saveBrandIdentity(AppLanguage lang) => _es(lang)
      ? 'Guardar y Aplicar Identidad de Marca'
      : 'Save and Apply Brand Identity';
  static String saving(AppLanguage lang) =>
      _es(lang) ? 'Guardando...' : 'Saving...';

  // Admin - Profile Tab
  static String adminProfileTitle(AppLanguage lang) =>
      _es(lang) ? 'Perfil del Administrador' : 'Administrator Profile';
  static String adminProfileSub(AppLanguage lang) => _es(lang)
      ? 'Credenciales institucionales, permisos y sesión activa.'
      : 'Institutional credentials, permissions and active session.';
  static String adminRole(AppLanguage lang) =>
      _es(lang) ? 'Administrador General' : 'General Administrator';
  static String adminBankRole(AppLanguage lang, String bank) =>
      _es(lang) ? 'Administrador $bank' : '$bank Administrator';
  static String idBadge(AppLanguage lang) =>
      _es(lang) ? 'ID de Matrícula' : 'License ID';
  static String assignedEntity(AppLanguage lang) =>
      _es(lang) ? 'Entidad Asignada' : 'Assigned Entity';
  static String tenantIdLabel(AppLanguage lang) =>
      _es(lang) ? 'Código Institucional' : 'Institutional Code';
  static String activeRegion(AppLanguage lang) =>
      _es(lang) ? 'Región Activa' : 'Active Region';
  static String accessLevel(AppLanguage lang) =>
      _es(lang) ? 'Nivel de Acceso' : 'Access Level';
  static String dataIsolation(AppLanguage lang) =>
      _es(lang) ? 'Protocolo de Seguridad' : 'Security Protocol';
  static String dedicatedSchemaValue(AppLanguage lang) => _es(lang)
      ? 'Cifrado Bancario 256-bit + Ledger Verificado'
      : '256-bit Banking Encryption + Verified Ledger';
  static String totalAccess(AppLanguage lang) =>
      _es(lang) ? 'Acceso Total' : 'Full Access';
  static String institutionalAccess(AppLanguage lang) =>
      _es(lang) ? 'Institucional' : 'Institutional';
  static String securityControlsTitle(AppLanguage lang) => _es(lang)
      ? 'Controles de Seguridad Institucional'
      : 'Institutional Security Controls';
  static String realTimeAuditTitle(AppLanguage lang) =>
      _es(lang) ? 'Auditoría en tiempo real' : 'Real-time Audit';
  static String realTimeAuditSub(AppLanguage lang) => _es(lang)
      ? 'Trazabilidad ISO 20022 activa'
      : 'ISO 20022 active traceability';
  static String twoFaTitle(AppLanguage lang) => _es(lang)
      ? 'Autenticación 2FA Institucional'
      : 'Institutional 2FA Authentication';
  static String twoFaSub(AppLanguage lang) =>
      _es(lang) ? 'Requerida en operaciones' : 'Required in operations';
  static String activeStatus(AppLanguage lang) =>
      _es(lang) ? 'Activa' : 'Active';
  static String pausedStatus(AppLanguage lang) =>
      _es(lang) ? 'Pausada' : 'Paused';
  static String requiredStatus(AppLanguage lang) =>
      _es(lang) ? 'Requerida' : 'Required';
  static String optionalStatus(AppLanguage lang) =>
      _es(lang) ? 'Opcional' : 'Optional';
  static String logoutConfirm(AppLanguage lang) =>
      _es(lang) ? 'Cerrar sesión' : 'Sign out';
  static String logoutAdminMessage(AppLanguage lang) => _es(lang)
      ? '¿Estás seguro de que deseas salir de la consola institucional de administración?'
      : 'Are you sure you want to sign out from the administrative console?';

  // Admin - Modal Crear Tenant
  static String modalCreateTitle(AppLanguage lang) =>
      _es(lang) ? 'Crear Nuevo Banco' : 'Create New Bank';
  static String modalCreateSub(AppLanguage lang) => _es(lang)
      ? 'Aprovisiona una nueva institución financiera en BankOs Cloud.'
      : 'Provision a new financial institution on BankOs Cloud.';
  static String bankNameLabel(AppLanguage lang) =>
      _es(lang) ? 'Nombre del Banco o Entidad:' : 'Bank or Entity Name:';
  static String codeLabel(AppLanguage lang) =>
      _es(lang) ? 'Código de Entidad:' : 'Entity Code:';
  static String currencyLabel(AppLanguage lang) =>
      _es(lang) ? 'Divisa Base Operativa:' : 'Base Operating Currency:';
  static String subdomainLabel(AppLanguage lang) =>
      _es(lang) ? 'Subdominio asignado:' : 'Assigned subdomain:';
  static String isolationInfo(AppLanguage lang) => _es(lang)
      ? 'Seguridad Bancaria de Alto Nivel con Entornos Protegidos.'
      : 'High-level Banking Security with Protected Environments.';
  static String provisionButton(AppLanguage lang) =>
      _es(lang) ? 'Crear Entidad Bancaria' : 'Create Banking Entity';

  // Operations
  static String depositFunds(AppLanguage lang) =>
      _es(lang) ? 'Depósito de Fondos' : 'Funds Deposit';
  static String withdrawFunds(AppLanguage lang) =>
      _es(lang) ? 'Retiro de Fondos' : 'Funds Withdrawal';
  static String originAccount(AppLanguage lang) => _es(lang)
      ? '1. Cuenta de origen (De dónde saldrán los fondos):'
      : '1. Origin account (Source of funds):';
  static String destAccount(AppLanguage lang) => _es(lang)
      ? '2. Cuenta destino (A dónde se van los fondos):'
      : '2. Destination account (Where funds go):';
  static String depositAmount(AppLanguage lang) =>
      _es(lang) ? '3. Monto a depositar:' : '3. Amount to deposit:';
  static String withdrawAmount(AppLanguage lang) =>
      _es(lang) ? '4. Monto a retirar:' : '4. Amount to withdraw:';
  static String conceptOptional(AppLanguage lang) =>
      _es(lang) ? 'Concepto (opcional):' : 'Concept (optional):';
  static String confirmDeposit(AppLanguage lang) =>
      _es(lang) ? 'Confirmar Depósito' : 'Confirm Deposit';
  static String confirmWithdraw(AppLanguage lang) =>
      _es(lang) ? 'Confirmar Retiro' : 'Confirm Withdrawal';
  static String withdrawBankLabel(AppLanguage lang) =>
      _es(lang) ? '1. Banco registrado:' : '1. Registered bank:';
  static String withdrawAccountLabel(AppLanguage lang) =>
      _es(lang) ? '2. Cuenta a debitar:' : '2. Account to debit:';
  static String withdrawNoAccount(AppLanguage lang) => _es(lang)
      ? 'No hay una cuenta activa disponible en este banco.'
      : 'No active account is available at this bank.';
  static String credentialsInvalid(AppLanguage lang) => _es(lang)
      ? 'Las credenciales son erróneas o no válidas.'
      : 'Your credentials are incorrect or invalid.';
  static String genericError(AppLanguage lang) => _es(lang)
      ? 'Ocurrió un error. Inténtalo de nuevo.'
      : 'Something went wrong. Please try again.';
  static String bankConnectionError(AppLanguage lang) => _es(lang)
      ? 'No fue posible conectar con el banco. Revisa tu conexión e inténtalo de nuevo.'
      : 'Could not connect to the bank. Check your connection and try again.';
  static String withdrawInactiveAccount(AppLanguage lang) => _es(lang)
      ? 'La cuenta seleccionada no se encuentra activa.'
      : 'The selected account is not active.';
  static String withdrawInvalidAmount(AppLanguage lang) => _es(lang)
      ? 'Ingresa un monto numérico válido.'
      : 'Enter a valid numeric amount.';
  static String withdrawPositiveAmount(AppLanguage lang) => _es(lang)
      ? 'El monto a retirar debe ser mayor que cero.'
      : 'The withdrawal amount must be greater than zero.';
  static String withdrawInsufficientFunds(
    AppLanguage lang,
    String balance,
    String debit,
    String amount,
    String currency,
    String requestedCurrency,
  ) => _es(lang)
      ? 'Saldo insuficiente ($balance). Se requieren $debit $currency para retirar $amount $requestedCurrency.'
      : 'Insufficient balance ($balance). $debit $currency is required to withdraw $amount $requestedCurrency.';
  static String withdrawPinTitle(AppLanguage lang, String bank) =>
      _es(lang) ? 'Retiro desde $bank' : 'Withdrawal from $bank';
  static String withdrawDefaultConcept(
    AppLanguage lang,
    String currency,
    String type,
  ) => _es(lang)
      ? 'Retiro en $currency desde $type'
      : 'Withdrawal in $currency from $type';
  static String withdrawSuccessTitle(AppLanguage lang) =>
      _es(lang) ? '¡Retiro exitoso!' : 'Withdrawal successful';
  static String withdrawSuccessMessage(
    AppLanguage lang,
    String amount,
    String currency,
    String bank,
  ) => _es(lang)
      ? 'Retiraste $amount $currency correctamente desde $bank.'
      : 'You withdrew $amount $currency from $bank successfully.';
  static String accept(AppLanguage lang) => _es(lang) ? 'Aceptar' : 'OK';
  static String amountHint(AppLanguage lang) => _es(lang) ? '0.00' : '0.00';
  static String withdrawConceptHint(AppLanguage lang) => _es(lang)
      ? 'Ej. Gastos personales, cajero'
      : 'E.g. Personal expenses, ATM';
  static String accountInactiveError(AppLanguage lang) => _es(lang)
      ? 'La cuenta no está activa. Contacta con tu banco para recibir ayuda.'
      : 'The account is not active. Contact your bank for assistance.';
  static String insufficientFundsError(AppLanguage lang) => _es(lang)
      ? 'No tienes saldo suficiente para completar esta operación.'
      : 'You do not have enough balance to complete this operation.';
  static String transactionLimitError(AppLanguage lang) => _es(lang)
      ? 'El monto supera el límite permitido para esta operación.'
      : 'The amount exceeds the allowed limit for this transaction.';
  static String exchangeRateError(AppLanguage lang) => _es(lang)
      ? 'No hay una tasa disponible para convertir estas monedas.'
      : 'No exchange rate is available for these currencies.';
  static String permissionError(AppLanguage lang) => _es(lang)
      ? 'No tienes autorización para realizar esta acción.'
      : 'You are not authorized to perform this action.';
  static String notFoundError(AppLanguage lang) => _es(lang)
      ? 'No se encontró la cuenta o el banco solicitado.'
      : 'The requested account or bank could not be found.';
  static String apiError(AppLanguage lang, int? status, String? code) {
    switch (code) {
      case 'BANKOS_INSUFFICIENT_FUNDS':
        return insufficientFundsError(lang);
      case 'BANKOS_TRANSACTION_LIMIT_EXCEEDED':
        return transactionLimitError(lang);
      case 'BANKOS_EXCHANGE_RATE_ERROR':
        return exchangeRateError(lang);
      case 'BANKOS_ACCOUNT_NOT_ACTIVE':
        return accountInactiveError(lang);
      case 'BANKOS_FORBIDDEN':
        return permissionError(lang);
      case 'BANKOS_NOT_FOUND':
        return notFoundError(lang);
    }
    if (status == 401) return credentialsInvalid(lang);
    if (status == 403) return permissionError(lang);
    if (status == 404) return notFoundError(lang);
    if (status == 400) {
      return _es(lang)
          ? 'Revisa los datos ingresados e inténtalo de nuevo.'
          : 'Check the information and try again.';
    }
    if (status == 409) {
      return _es(lang)
          ? 'La solicitud coincide con una operación reciente. Actualiza e inténtalo de nuevo.'
          : 'This request conflicts with a recent operation. Refresh and try again.';
    }
    if (status == 429) {
      return _es(lang)
          ? 'Hay demasiados intentos. Espera un momento e inténtalo de nuevo.'
          : 'Too many attempts. Wait a moment and try again.';
    }
    return _es(lang)
        ? 'El servicio bancario no está disponible por el momento. Inténtalo más tarde.'
        : 'The banking service is temporarily unavailable. Please try again later.';
  }

  static String withdrawCurrencyLabel(AppLanguage lang) =>
      _es(lang) ? '3. Divisa a retirar:' : '3. Currency to withdraw:';

  // Conversion Card
  static String conversionTitle(AppLanguage lang) => _es(lang)
      ? 'Conversión a Dólares y Euros (Tiempo Real):'
      : 'Real-Time Dollar & Euro Conversion:';
  static String conversionTitleForPair(
    AppLanguage lang,
    String from,
    String to,
  ) => _es(lang)
      ? 'Conversión en Tiempo Real ($from ⇄ $to):'
      : 'Real-Time Conversion ($from ⇄ $to):';
  static String amountToDebit(AppLanguage lang) =>
      _es(lang) ? 'Monto a debitar' : 'Amount to debit';
  static String amountToCredit(AppLanguage lang) =>
      _es(lang) ? 'Abono estimado' : 'Estimated credit';
  static String amountToWithdraw(AppLanguage lang) =>
      _es(lang) ? 'Monto a retirar' : 'Amount to withdraw';
  static String cardDebit(AppLanguage lang) =>
      _es(lang) ? 'Débito de tarjeta' : 'Card debit';
  static String originAccountSub(AppLanguage lang) =>
      _es(lang) ? 'Cuenta de origen' : 'Origin account';
  static String destAccountSub(AppLanguage lang) =>
      _es(lang) ? 'Cuenta de destino' : 'Destination account';
  static String withdrawCashSub(AppLanguage lang) =>
      _es(lang) ? 'Divisa de retiro' : 'Withdrawal currency';
  static String systemRateApplied(
    AppLanguage lang,
    String from,
    String rate,
    String to,
  ) => _es(lang)
      ? 'Tasa oficial: 1 $from = $rate $to'
      : 'Official rate: 1 $from = $rate $to';
  static String inDollars(AppLanguage lang) =>
      _es(lang) ? 'En Dólares' : 'In Dollars';
  static String inEuros(AppLanguage lang) =>
      _es(lang) ? 'En Euros' : 'In Euros';
  static String estimatedDestination(AppLanguage lang, String dest) => _es(lang)
      ? 'Abono estimado en destino ($dest):'
      : 'Estimated credit at destination ($dest):';
  static String tenantRatesLabel(AppLanguage lang) => _es(lang)
      ? 'Tasas de Cambio: 1 USD ≈ \$4,150 COP • 1 EUR ≈ 1.08 USD'
      : 'Exchange Rates: 1 USD ≈ \$4,150 COP • 1 EUR ≈ 1.08 USD';
  static String noHiddenSpread(AppLanguage lang) =>
      _es(lang) ? 'Sin spread oculto' : 'No hidden spread';

  // History Screen
  static String historyTitle(AppLanguage lang) =>
      _es(lang) ? 'Historial de Operaciones' : 'Operations History';
  static String searchMovement(AppLanguage lang) =>
      _es(lang) ? 'Buscar movimiento...' : 'Search transactions...';
  static String filterHistoryAll(AppLanguage lang) =>
      _es(lang) ? 'Todos' : 'All';
  static String filterHistoryDeposits(AppLanguage lang) =>
      _es(lang) ? 'Depósitos' : 'Deposits';
  static String filterHistoryWithdrawals(AppLanguage lang) =>
      _es(lang) ? 'Retiros' : 'Withdrawals';
  static String filterHistoryExchange(AppLanguage lang) =>
      _es(lang) ? 'Cambio Divisa' : 'Currency Exchange';
  static String noTransactionsHistory(AppLanguage lang) => _es(lang)
      ? 'No hay transacciones registradas'
      : 'No transactions recorded';
  static String monthShort(AppLanguage lang, int month) => _es(lang)
      ? const [
          'ene',
          'feb',
          'mar',
          'abr',
          'may',
          'jun',
          'jul',
          'ago',
          'sep',
          'oct',
          'nov',
          'dic',
        ][month - 1]
      : const [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ][month - 1];
}
