import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:bankos_frontend/app.dart';

void main() {
  testWidgets(
      'Full BankOS Navigation Flow (Launch -> Onboarding -> Login -> Select Tenant -> Home -> Operations & Profile)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BankOsApp()));
    await tester.pump();

    // 1. Initial frame renders LaunchScreen
    expect(find.text('BankOs'), findsOneWidget);

    // 2. Advance time past the 2.4s transition timer to OnboardingScreen
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.text('Banca digital\nsegura'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
    expect(find.text('Omitir'), findsOneWidget);

    // 3. Tap "Omitir" to navigate to SelectTenantScreen (Portal / Dashboard de Bancos Registrados)
    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();

    // Portal Central de Bancos Registrados (El usuario ve los bancos ANTES de iniciar sesión)
    expect(find.text('Elige tu Entidad Financiera'), findsOneWidget);
    expect(find.text('Banco / Tenant a ingresar:'), findsOneWidget);

    // 4. Seleccionar e ingresar a la entidad financiera seleccionada -> Lleva a LoginScreen
    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pumpAndSettle();

    // Clean Login Screen para el banco elegido
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNWidgets(2));
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
    expect(find.text('Ingresar con huella digital'), findsOneWidget);

    // 5. Test Navigation to Progressive Register Screen
    await tester.tap(find.text('Registrarse'));
    await tester.pumpAndSettle();

    expect(find.text('Registro de Cliente'), findsOneWidget);
    expect(find.text('Paso 1 de 5'), findsOneWidget);
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    expect(find.text('Nombre completo:'), findsOneWidget);
    expect(find.text('Carlos Gómez'), findsOneWidget);

    // Go back to Login
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    // 6. Enter credentials on LoginScreen -> routes directly to HomeScreen
    await tester.enterText(find.byType(TextField).at(0), 'cliente@bancolombia.com');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pumpAndSettle();

    // 7. Now on BankOS HomeScreen with dynamic user greeting and bank branding
    expect(find.textContaining('¡Hola,'), findsOneWidget);
    expect(find.text('Cambiar'), findsOneWidget);
    expect(find.text('Dinero actual:'), findsOneWidget);
    expect(find.text('Operaciones Financieras'), findsOneWidget);
    expect(find.text('Depósito'), findsOneWidget);
    expect(find.text('Retiro'), findsOneWidget);
    expect(find.text('Transacciones hechas'), findsOneWidget);

    // Test Account Switcher Modal & Multi-currency balances
    await tester.tap(find.text('Cambiar'));
    await tester.pumpAndSettle();

    expect(find.text('Cuentas y Bancos Registrados'), findsOneWidget);
    expect(find.text('CUENTA GLOBAL PRINCIPAL'), findsOneWidget);

    // Close switcher modal
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Bottom Navigation Bar tabs (Inicio, Historial, Perfil)
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);

    // 7. Test Depósito Screen with Banks and Dynamic Cards Dropdowns
    await tester.tap(find.text('Depósito'));
    await tester.pumpAndSettle();

    expect(find.text('Depósito de Fondos'), findsOneWidget);
    expect(find.text('1. Cuenta de origen (De dónde saldrán los fondos):'), findsOneWidget);
    expect(find.text('2. Cuenta destino (A dónde se van los fondos):'), findsOneWidget);
    expect(find.text('3. Monto a depositar:'), findsOneWidget);
    expect(find.text('Confirmar Depósito'), findsOneWidget);

    // Return to Home
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // 8. Test Retiro Screen with Banks and Dynamic Cards Dropdowns
    await tester.tap(find.text('Retiro'));
    await tester.pumpAndSettle();

    expect(find.text('Retiro de Fondos'), findsOneWidget);
    expect(find.text('1. Banco registrado:'), findsOneWidget);
    expect(find.text('2. Tarjetas anexadas a este banco:'), findsOneWidget);
    expect(find.text('3. Divisa a retirar:'), findsOneWidget);
    expect(find.text('4. Monto a retirar:'), findsOneWidget);
    // El banco activo es Cuenta Global BankOs (USD) y la divisa a retirar por defecto es USD:
    // Al ser la misma divisa, NO debe aparecer conversión en tiempo real
    expect(find.textContaining('Conversión en Tiempo Real'), findsNothing);

    // Si seleccionamos retirar en EUR, debe mostrarse la conversión dinámica
    await tester.tap(find.text('EUR (€)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Conversión en Tiempo Real'), findsOneWidget);
    expect(find.text('Confirmar Retiro'), findsOneWidget);

    // Return to Home
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    // 9. Test Bottom Navigation Bar: Tap 'Perfil' tab
    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Alejandro Morales'), findsOneWidget);
    expect(find.text('cliente@bancolombia.com'), findsOneWidget);
    expect(find.text('Datos personales'), findsOneWidget);
    expect(find.text('Seguridad'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.textContaining('Ayuda'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });
}
