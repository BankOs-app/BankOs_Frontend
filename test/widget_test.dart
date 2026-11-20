import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:bankos_frontend/app.dart';

void main() {
  testWidgets(
    'Full BankOS Navigation Flow (Launch -> Select Tenant -> Login -> Register -> Home -> Operations & Profile)',
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

      // 2. Advance time past the launch transition timer into Onboarding, then skip to SelectTenant
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pumpAndSettle();

      if (find.text('Omitir').evaluate().isNotEmpty) {
        await tester.tap(find.text('Omitir'));
        await tester.pumpAndSettle();
      }

      // Portal Central de Bancos Registrados (El usuario ve los bancos directamente)
      expect(find.text('Seleccionar Entidad'), findsOneWidget);

      // 3. Seleccionar e ingresar a la entidad financiera seleccionada directamente al presionar su tarjeta
      await tester.tap(find.text('Bancolombia').first);
      await tester.pumpAndSettle();

      // Clean Login Screen para el banco elegido
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsNWidgets(2));
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
      expect(find.text('Ingresar con huella dactilar'), findsOneWidget);

      // 5. Test Navigation to Progressive Register Screen
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();

      expect(find.text('Registro de Cliente'), findsOneWidget);
      expect(find.text('Paso 1 de 6'), findsOneWidget);
      expect(find.text('¿Cómo te llamas?'), findsOneWidget);
      expect(find.text('Nombre completo:'), findsOneWidget);
      expect(find.text('Carlos Gómez'), findsOneWidget);

      // Go back to Login
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pumpAndSettle();

      // 6. Enter credentials on LoginScreen -> routes directly to HomeScreen
      await tester.enterText(
        find.byType(TextField).at(0),
        'cliente@bancolombia.com',
      );
      await tester.enterText(find.byType(TextField).at(1), '1234');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
      await tester.pumpAndSettle();

      // 7. Now on BankOS HomeScreen with dynamic user greeting and bank branding
      expect(find.textContaining('¡Hola,'), findsOneWidget);
      expect(find.text('Dinero actual:'), findsOneWidget);
      expect(find.text('Operaciones Financieras'), findsOneWidget);
      expect(find.text('Transferir'), findsOneWidget);
      expect(find.text('Retiro'), findsOneWidget);
      expect(find.text('Transacciones hechas'), findsOneWidget);

      // Bottom Navigation Bar tabs (Inicio, Historial, Perfil)
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Historial'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);

      // 8. Test transfers using the signed-in origin account and a destination account number.
      await tester.tap(find.text('Transferir'));
      await tester.pumpAndSettle();

      expect(find.text('Transferencia de fondos'), findsOneWidget);
      expect(
        find.text('1. Cuenta de origen (desde donde se enviarán los fondos):'),
        findsOneWidget,
      );
      expect(
        find.text('2. Cuenta destino (donde se recibirán los fondos):'),
        findsOneWidget,
      );
      expect(find.text('3. Monto a transferir:'), findsOneWidget);
      expect(find.text('Continuar y revisar conversión'), findsOneWidget);

      // Return to Home
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // 9. Test withdrawal from the bank and account associated with this session.
      await tester.tap(find.text('Retiro'));
      await tester.pumpAndSettle();

      expect(find.text('Retiro de Fondos'), findsOneWidget);
      expect(find.text('1. Banco registrado:'), findsOneWidget);
      expect(find.text('2. Cuenta a debitar:'), findsOneWidget);
      expect(find.text('Confirmar Retiro'), findsOneWidget);

      // Return to Home
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      // 10. Test Bottom Navigation Bar: Tap 'Perfil' tab
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('Alejandro Morales'), findsOneWidget);
      expect(find.text('cliente@bancolombia.com'), findsOneWidget);
      expect(find.text('Datos personales'), findsOneWidget);
      expect(find.text('Seguridad'), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);
      expect(find.textContaining('Ayuda'), findsOneWidget);
      expect(find.text('Cerrar sesión'), findsOneWidget);
    },
  );
}
