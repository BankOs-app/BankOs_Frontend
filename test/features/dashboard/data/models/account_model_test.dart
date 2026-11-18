import 'package:flutter_test/flutter_test.dart';
import 'package:bankos_frontend/features/dashboard/data/models/account_model.dart';
import 'package:bankos_frontend/features/dashboard/domain/entities/account_entity.dart';

void main() {
  const tAccountModel = AccountModel(
    id: 'acc_001',
    accountNumber: '4829',
    accountType: 'Checking Account',
    balance: 12450000.0,
    currency: 'COP',
    isActive: true,
  );

  test('AccountModel should be a subclass of AccountEntity', () {
    expect(tAccountModel, isA<AccountEntity>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      final jsonMap = {
        'id': 'acc_001',
        'accountNumber': '4829',
        'accountType': 'Checking Account',
        'balance': 12450000.0,
        'currency': 'COP',
        'isActive': true,
      };

      final result = AccountModel.fromJson(jsonMap);

      expect(result.id, 'acc_001');
      expect(result.accountNumber, '4829');
      expect(result.balance, 12450000.0);
      expect(result.currency, 'COP');
      expect(result.isActive, true);
      expect(result.maskedAccountNumber, '•••• 4829');
      expect(result.formattedBalance, '\$12,450,000 COP');
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      final result = tAccountModel.toJson();

      final expectedMap = {
        'id': 'acc_001',
        'accountNumber': '4829',
        'accountType': 'Checking Account',
        'balance': 12450000.0,
        'currency': 'COP',
        'isActive': true,
      };

      expect(result, expectedMap);
    });
  });
}
