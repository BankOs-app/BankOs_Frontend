import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:bankos_frontend/features/auth/presentation/screens/register_screen.dart';

void main() {
  testWidgets('RegisterScreen - Flujo Progresivo por Pasos Transicionales',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: RegisterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. PASO 1: Nombre Completo
    expect(find.text('Registro de Cliente'), findsOneWidget);
    expect(find.text('Paso 1 de 6'), findsOneWidget);
    expect(find.text('¿Cómo te llamas?'), findsOneWidget);
    expect(find.text('Nombre completo:'), findsOneWidget);

    // Intentar continuar vacío debe bloquear
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.text('Por favor, ingresa tu nombre completo.'), findsOneWidget);

    // Escribir nombre válido y continuar al Paso 2
    await tester.enterText(find.byType(TextField).first, 'Alejandro Morales');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // 2. PASO 2: Documento de Identidad
    expect(find.text('Paso 2 de 6'), findsOneWidget);
    expect(find.text('¿Cuál es tu identificación?'), findsOneWidget);
    expect(find.text('Número de documento:'), findsOneWidget);

    // Escribir documento válido y avanzar al Paso 3
    await tester.enterText(find.byType(TextField).first, '1032456789');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // 3. PASO 3: Correo Electrónico
    expect(find.text('Paso 3 de 6'), findsOneWidget);
    expect(find.text('¿Cuál es tu correo electrónico?'), findsOneWidget);
    expect(find.text('Correo electrónico:'), findsOneWidget);

    // Escribir correo y avanzar al Paso 4
    await tester.enterText(find.byType(TextField).first, 'alejandro@bankos.com');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // 4. PASO 4: Celular
    expect(find.text('Paso 4 de 6'), findsOneWidget);
    expect(find.text('¿Cuál es tu número celular?'), findsOneWidget);
    expect(find.text('Teléfono:'), findsOneWidget);

    // Escribir teléfono y avanzar al Paso 5
    await tester.enterText(find.byType(TextField).first, '3001234567');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // 5. PASO 5: Contraseña de Acceso
    expect(find.text('Paso 5 de 6'), findsOneWidget);
    expect(find.text('Crea tu clave de acceso'), findsOneWidget);
    expect(find.text('Contraseña:'), findsOneWidget);
    expect(find.text('Verificación de contraseña:'), findsOneWidget);

    // Escribir contraseña y avanzar al Paso 6
    await tester.enterText(find.byType(TextField).at(0), '123456');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // 6. PASO 6: PIN Transaccional de 4 Dígitos
    expect(find.text('Paso 6 de 6'), findsOneWidget);
    expect(find.text('Crea tu PIN de seguridad'), findsOneWidget);
    expect(find.text('PIN Transaccional (4 dígitos):'), findsOneWidget);
    expect(find.text('Confirma tu PIN:'), findsOneWidget);
    expect(find.text('Crear mi cuenta'), findsOneWidget);

    // Probar el botón "Atrás" para regresar de forma transitiva
    await tester.tap(find.text('Atrás'));
    await tester.pumpAndSettle();
    expect(find.text('Paso 5 de 6'), findsOneWidget);
    expect(find.text('Crea tu clave de acceso'), findsOneWidget);
  });
}
