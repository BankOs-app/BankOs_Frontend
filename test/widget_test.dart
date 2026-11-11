import 'package:flutter_test/flutter_test.dart';
import 'package:bankos_frontend/main.dart';

void main() {
  testWidgets('BankOS smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BankOsApp());

    // Verify key UI elements are displayed in English.
    expect(find.text('Hello, World!'), findsOneWidget);
    expect(find.text('BankOS'), findsWidgets);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
