import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bankos_frontend/features/operations/domain/entities/operation_record_entity.dart';
import 'package:bankos_frontend/features/operations/presentation/widgets/transaction_detail_modal.dart';
import 'package:bankos_frontend/core/localization/app_locale_provider.dart';

void main() {
  group('OperationRecordEntity Tests', () {
    test('Incoming transfer has isCredit=true and + in formattedAmount', () {
      final record = OperationRecordEntity(
        id: 'tx_test_1',
        type: OperationType.internalTransfer,
        title: 'Transferencia recibida',
        description: 'De: Banco de NU • Cta: 8008008001',
        amount: 200000.0,
        currency: 'COP',
        timestamp: DateTime(2026, 11, 20, 10, 30),
        originAccountId: 'acc_nu_01',
        destinationAccountId: 'acc_col_01',
        sourceBankName: 'Banco de NU',
        destinationBankName: 'Bancolombia',
        sourceAccountNumber: '8008008001',
        destinationAccountNumber: '7007007001',
        isIncoming: true,
      );

      expect(record.isCredit, isTrue);
      expect(record.formattedAmount, equals('+\$200,000 COP'));
      expect(record.sourceBankName, equals('Banco de NU'));
      expect(record.destinationBankName, equals('Bancolombia'));
      expect(record.sourceAccountNumber, equals('8008008001'));
      expect(record.destinationAccountNumber, equals('7007007001'));
    });

    test('Outgoing transfer has isCredit=false and - in formattedAmount', () {
      final record = OperationRecordEntity(
        id: 'tx_test_2',
        type: OperationType.internalTransfer,
        title: 'Transferencia realizada',
        description: 'Para: Banco Santander • Cta: 9009009001',
        amount: 52500.0,
        currency: 'COP',
        timestamp: DateTime(2026, 11, 20, 11, 00),
        originAccountId: 'acc_col_01',
        destinationAccountId: 'acc_sant_01',
        sourceBankName: 'Bancolombia',
        destinationBankName: 'Banco Santander',
        sourceAccountNumber: '7007007001',
        destinationAccountNumber: '9009009001',
        isIncoming: false,
      );

      expect(record.isCredit, isFalse);
      expect(record.formattedAmount, equals('-\$52,500 COP'));
    });

    test('Deposit has isCredit=true and + in formattedAmount', () {
      final record = OperationRecordEntity(
        id: 'dep_test_1',
        type: OperationType.deposit,
        title: 'Depósito bancario',
        description: 'Abono en Bancolombia • Cta: 7007007001',
        amount: 1000000.0,
        currency: 'COP',
        timestamp: DateTime(2026, 11, 20, 12, 00),
        originAccountId: 'acc_col_01',
        destinationBankName: 'Bancolombia',
        destinationAccountNumber: '7007007001',
      );

      expect(record.isCredit, isTrue);
      expect(record.formattedAmount, equals('+\$1,000,000 COP'));
    });
  });

  group('TransactionDetailModal Widget Tests', () {
    testWidgets('renders receipt details properly', (tester) async {
      final record = OperationRecordEntity(
        id: 'tx_rec_1234567890abcdef',
        type: OperationType.internalTransfer,
        title: 'Transferencia recibida',
        description: 'De: Banco de NU • Cta: 8008008001',
        amount: 200000.0,
        currency: 'COP',
        timestamp: DateTime(2026, 11, 20, 14, 30),
        originAccountId: 'acc_nu_01',
        destinationAccountId: 'acc_col_01',
        sourceBankName: 'Banco de NU',
        destinationBankName: 'Bancolombia',
        sourceAccountNumber: '8008008001',
        destinationAccountNumber: '7007007001',
        isIncoming: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionDetailModal(
              record: record,
              lang: AppLanguage.es,
            ),
          ),
        ),
      );

      expect(find.text('Transferencia recibida'), findsOneWidget);
      expect(find.text('Transacción Exitosa'), findsOneWidget);
      expect(find.text('+\$200,000 COP'), findsOneWidget);
      expect(find.text('Banco Origen'), findsOneWidget);
      expect(find.text('Banco de NU'), findsOneWidget);
      expect(find.text('8008008001'), findsOneWidget);
      expect(find.text('Banco Destino'), findsOneWidget);
      expect(find.text('Bancolombia'), findsOneWidget);
      expect(find.text('7007007001'), findsOneWidget);
      expect(find.text('Cerrar Comprobante'), findsOneWidget);
    });
  });
}
