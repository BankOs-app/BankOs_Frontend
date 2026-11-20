import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bankos_frontend/features/operations/presentation/screens/deposit_screen.dart';

void main() {
  testWidgets('DepositScreen renders default session account and elements', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DepositScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Depósito de fondos'), findsOneWidget);
    expect(find.text('1. Banco registrado:'), findsOneWidget);
    expect(find.text('2. Cuenta a acreditar (donde se recibirán los fondos):'), findsOneWidget);
    expect(find.text('3. Monto a depositar:'), findsOneWidget);
    expect(find.text('Continuar y depositar'), findsOneWidget);
  });
}
