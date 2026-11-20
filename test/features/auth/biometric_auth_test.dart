import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bankos_frontend/features/auth/presentation/widgets/biometric_auth_modal.dart';
import 'package:bankos_frontend/core/localization/app_locale_provider.dart';

void main() {
  group('BiometricAuthModal Tests', () {
    testWidgets('renders fingerprint authentication on Android', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiometricAuthModal(
              bankName: 'Bancolombia',
              userEmail: 'cliente@bancolombia.com',
              userName: 'Alejandro Morales',
              isApple: false,
              lang: AppLanguage.es,
              autoScan: false,
            ),
          ),
        ),
      );

      expect(find.text('Autenticación con Huella Dactilar'), findsOneWidget);
      expect(find.text('Alejandro Morales'), findsOneWidget);
      expect(find.text('cliente@bancolombia.com'), findsOneWidget);
      expect(find.text('Enrolado'), findsOneWidget);
      expect(find.text('Cancelar / Usar contraseña'), findsOneWidget);
    });

    testWidgets('renders Face ID authentication on Apple', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BiometricAuthModal(
              bankName: 'Banco de NU',
              userEmail: 'cliente@nu.com',
              userName: 'Catalina Restrepo',
              isApple: true,
              lang: AppLanguage.es,
              autoScan: false,
            ),
          ),
        ),
      );

      expect(find.text('Autenticación con Face ID'), findsOneWidget);
      expect(find.text('Catalina Restrepo'), findsOneWidget);
      expect(find.text('cliente@nu.com'), findsOneWidget);
    });
  });
}
