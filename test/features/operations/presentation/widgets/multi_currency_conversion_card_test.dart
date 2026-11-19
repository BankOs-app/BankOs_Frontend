import 'package:bankos_frontend/features/operations/presentation/widgets/multi_currency_conversion_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Widget createWidget({
    required String originCurrency,
    required String destinationCurrency,
    required double amount,
    bool isWithdrawal = false,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: MultiCurrencyConversionCard(
            originCurrency: originCurrency,
            destinationCurrency: destinationCurrency,
            amount: amount,
            isWithdrawal: isWithdrawal,
          ),
        ),
      ),
    );
  }

  group('MultiCurrencyConversionCard - Visibilidad y Divisas Requeridas', () {
    testWidgets('Si origen y destino son COP (ambas en pesos), no se muestra nada',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          originCurrency: 'COP',
          destinationCurrency: 'COP',
          amount: 25000,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Conversión en Tiempo Real'), findsNothing);
      expect(find.text('USD'), findsNothing);
      expect(find.text('EUR'), findsNothing);
    });

    testWidgets('Si origen y destino son USD (ambas en dólares), no se muestra nada',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          originCurrency: 'USD',
          destinationCurrency: 'USD',
          amount: 100,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Conversión en Tiempo Real'), findsNothing);
      expect(find.text('EUR'), findsNothing);
      expect(find.text('COP'), findsNothing);
    });

    testWidgets(
        'Depósito: De USD a COP (cuenta en dólar a pasar a pesos) solo muestra USD y COP (nunca EUR)',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          originCurrency: 'USD',
          destinationCurrency: 'COP',
          amount: 10,
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.text('Conversión en Tiempo Real (USD ⇄ COP):'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('COP'), findsOneWidget);
      expect(find.text('EUR'), findsNothing);
      expect(find.textContaining('41,500'), findsOneWidget);
    });

    testWidgets(
        'Depósito: De EUR a USD (cuenta en euro a pasar a dólar) solo muestra EUR y USD (nunca COP)',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          originCurrency: 'EUR',
          destinationCurrency: 'USD',
          amount: 100,
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.text('Conversión en Tiempo Real (EUR ⇄ USD):'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('COP'), findsNothing);
      expect(find.textContaining('108'), findsOneWidget);
    });

    testWidgets(
        'Retiro: Tarjeta COP y se retira en USD (pesos a pasar a dólar y viceversa)',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          originCurrency: 'COP', // tarjeta
          destinationCurrency: 'USD', // divisa retiro
          amount: 10, // 10 USD
          isWithdrawal: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.text('Conversión en Tiempo Real (USD ⇄ COP):'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('COP'), findsOneWidget);
      expect(find.text('EUR'), findsNothing);
      expect(find.text('Monto a retirar'), findsOneWidget);
      expect(find.text('Débito de tarjeta'), findsOneWidget);
      expect(find.textContaining('41,500'), findsOneWidget);
    });

    testWidgets(
        'Retiro: Tarjeta USD y se retira en EUR (dólares a pasar a euro)',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          originCurrency: 'USD',
          destinationCurrency: 'EUR',
          amount: 50,
          isWithdrawal: true,
        ),
      );
      await tester.pumpAndSettle();

      expect(
          find.text('Conversión en Tiempo Real (EUR ⇄ USD):'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('COP'), findsNothing);
    });
  });
}
