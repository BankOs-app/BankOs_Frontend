import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bankos_frontend/main.dart';

void main() {
  testWidgets('Launch and Onboarding smoke test', (WidgetTester tester) async {
    // Build app wrapped in ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Initial frame renders LaunchScreen with BankOs logo
    expect(find.text('BankOs'), findsOneWidget);

    // Advance time past the 2.4s transition timer
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Screen transitions to OnboardingScreen
    expect(find.text('Toma el control\nde tus finanzas'), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Saltar'), findsOneWidget);

    // Tap "Saltar" to navigate directly to Home
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    // Now on HomeScreen
    expect(find.text('Hello world'), findsOneWidget);
    expect(find.text('BankOS - Home'), findsOneWidget);
  });
}
